import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/widgets/custom_footer.dart';
import '../../domain/models/place_activity.dart';

// Mapeia o nome da categoria (salvo no Firestore) pro ícone correspondente.
// Mesmo mapeamento usado no card da lista de descoberta.
IconData _iconForCategory(String category) {
  switch (category) {
    case 'Cafeterias':
      return Icons.local_cafe;
    case 'Restaurantes':
      return Icons.restaurant;
    case 'Lazer':
      return Icons.park;
    default:
      return Icons.place;
  }
}

// Mapeia o valor técnico salvo no Firestore (no plural, usado também pra
// montar o caminho das pastas de imagem) pro nome de exibição no singular,
// que fica mais natural quando se refere a um lugar específico.
const Map<String, String> _categoryDisplayNames = {
  'Cafeterias': 'Cafeteria',
  'Restaurantes': 'Restaurante',
  'Lazer': 'Lazer',
};

String _displayCategory(String category) {
  return _categoryDisplayNames[category] ?? category;
}

class DetailScreen extends StatefulWidget {
  const DetailScreen({
    required this.place,
    super.key,
  });

  final PlaceActivity place;

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  late PageController _imageController;
  int _currentImageIndex = 0;
  bool _showAllHours = false;

  @override
  void initState() {
    super.initState();
    _imageController = PageController();
  }

  @override
  void dispose() {
    _imageController.dispose();
    super.dispose();
  }

  List<Map<String, String>> _parseOperatingHours(String hours) {
    final parts = hours
        .replaceAll('\n', ' | ')
        .split('|')
        .map((item) => item.trim())
        .where((item) => item.isNotEmpty)
        .toList();

    final result = <Map<String, String>>[];

    for (final part in parts) {
      final separatorIndex = part.indexOf(':');

      if (separatorIndex > 0) {
        final day = part.substring(0, separatorIndex).trim();
        final time = part.substring(separatorIndex + 1).trim();

        result.add({
          'day': day,
          'time': time,
        });
      } else {
        result.add({
          'day': part,
          'time': '',
        });
      }
    }

    return result;
  }

  // Extrai todos os intervalos "HH:MM - HH:MM" de um texto, não importa
  // se estão separados por vírgula, espaço, travessão (–) ou hífen (-).
  // Ex: "11:30 - 15:00 18:30 – 23:00" -> ["11:30 - 15:00", "18:30 - 23:00"]
  List<String> _extractTimeRanges(String text) {
    final regex = RegExp(r'(\d{1,2}:\d{2})\s*[-–]\s*(\d{1,2}:\d{2})');
    return regex
        .allMatches(text)
        .map((m) => '${m.group(1)} - ${m.group(2)}')
        .toList();
  }

  // Verifica se um trecho de texto indica funcionamento 24 horas.
  // Cobre variações como "24 horas", "24hs", "24h", "aberto 24h".
  bool _mentions24Hours(String text) {
    final lower = text.toLowerCase();
    return lower.contains('24 hora') ||
        lower.contains('24hora') ||
        lower.contains('24h');
  }

  // ==========================================================
  // LÓGICA DE FUNCIONAMENTO (ABERTO / FECHADO) EM TEMPO REAL
  // ==========================================================
  Map<String, dynamic> _checkIfOpen(String hoursString) {
    if (hoursString.trim().isEmpty) {
      return {'isOpen': false, 'statusText': 'Horário não informado'};
    }

    final now = DateTime.now();
    final weekdaysMap = {
      1: 'segunda',
      2: 'terça',
      3: 'quarta',
      4: 'quinta',
      5: 'sexta',
      6: 'sábado',
      7: 'domingo',
    };
    final currentDayKey = weekdaysMap[now.weekday] ?? '';

    final parsed = _parseOperatingHours(hoursString);

    // Caso o campo inteiro seja algo como "Aberto 24 horas", sem quebra
    // por dia da semana (uma única entrada, sem estrutura por dia).
    if (parsed.length == 1) {
      final combined =
          '${parsed.first['day']} ${parsed.first['time']}'.trim();
      if (_mentions24Hours(combined)) {
        return {'isOpen': true, 'statusText': 'Aberto · Funciona 24 horas'};
      }
    }

    Map<String, String>? todaySchedule;
    for (var item in parsed) {
      final dayLower = item['day']!.toLowerCase();
      if (dayLower.contains(currentDayKey)) {
        todaySchedule = item;
        break;
      }
    }

    if (todaySchedule == null || todaySchedule['time']!.toLowerCase().contains('fechado')) {
      return {'isOpen': false, 'statusText': 'Fechado hoje'};
    }

    final timeStr = todaySchedule['time']!;

    // Caso o dia de hoje esteja marcado como funcionamento 24 horas,
    // ex: "Segunda: Aberto 24 horas".
    if (_mentions24Hours(timeStr)) {
      return {'isOpen': true, 'statusText': 'Aberto · Funciona 24 horas'};
    }

    final intervals = _extractTimeRanges(timeStr);

    bool isOpenNow = false;
    String extraInfo = '';
    final currentMinutes = now.hour * 60 + now.minute;

    for (var interval in intervals) {
      final parts = interval.trim().split('-');
      if (parts.length == 2) {
        final openParts = parts[0].trim().split(':');
        final closeParts = parts[1].trim().split(':');

        if (openParts.length == 2 && closeParts.length == 2) {
          final openM = int.parse(openParts[0]) * 60 + int.parse(openParts[1]);
          final closeM = int.parse(closeParts[0]) * 60 + int.parse(closeParts[1]);

          if (currentMinutes >= openM && currentMinutes <= closeM) {
            isOpenNow = true;
            final closingTimeStr = parts[1].trim();
            extraInfo = 'Fecha $closingTimeStr';
            break;
          } else if (currentMinutes < openM) {
            final openingTimeStr = parts[0].trim();
            if (extraInfo.isEmpty) {
              extraInfo = 'Abre às $openingTimeStr';
            }
          }
        }
      }
    }

    if (isOpenNow) {
      return {
        'isOpen': true,
        'statusText': 'Aberto${extraInfo.isNotEmpty ? ' · $extraInfo' : ''}'
      };
    } else {
      return {
        'isOpen': false,
        'statusText': 'Fechado${extraInfo.isNotEmpty ? ' · $extraInfo' : ''}'
      };
    }
  }

  Widget _buildOperatingHours() {
    final hours = widget.place.operatingHours.trim();

    if (hours.isEmpty) {
      return const Text(
        'Horário não informado.',
        style: TextStyle(
          fontFamily: 'Raleway',
          fontSize: 16,
          color: Colors.black87,
        ),
      );
    }

    final parsedHours = _parseOperatingHours(hours);
    final statusData = _checkIfOpen(hours);
    final bool isOpen = statusData['isOpen'];
    final String statusText = statusData['statusText'];

    final now = DateTime.now();
    final weekdaysMap = {
      1: 'segunda',
      2: 'terça',
      3: 'quarta',
      4: 'quinta',
      5: 'sexta',
      6: 'sábado',
      7: 'domingo',
    };
    final currentDayKey = weekdaysMap[now.weekday] ?? '';

    // Se o horário for simples (<= 2 linhas)
    if (parsedHours.length <= 2) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Image.asset(
            'assets/images/elderly/opening_hours.png',
            width: 20,
            height: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      isOpen ? 'Aberto' : 'Fechado',
                      style: TextStyle(
                        fontFamily: 'Raleway',
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isOpen ? Colors.green[700] : Colors.red[700],
                      ),
                    ),
                    const Text(' · ', style: TextStyle(fontSize: 16)),
                    Expanded(
                      child: Text(
                        statusText.replaceAll(RegExp(r'^(Aberto|Fechado)(\s*·\s*)?'), ''),
                        style: const TextStyle(
                          fontFamily: 'Raleway',
                          fontSize: 16,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      );
    }

    // Horários completos no padrão estilo Google Maps
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/elderly/opening_hours.png',
              width: 20,
              height: 20,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Row(
                children: [
                  Expanded(
                    child: RichText(
                      text: TextSpan(
                        style: const TextStyle(
                          fontFamily: 'Raleway',
                          fontSize: 16,
                          color: Colors.black87,
                        ),
                        children: [
                          TextSpan(
                            text: isOpen ? 'Aberto' : 'Fechado',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: isOpen ? Colors.green[700] : Colors.red[700],
                            ),
                          ),
                          TextSpan(
                            text:
                                ' · ${statusText.replaceAll(RegExp(r'^(Aberto|Fechado)(\s*·\s*)?'), '')}',
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  InkWell(
                    onTap: () {
                      setState(() {
                        _showAllHours = !_showAllHours;
                      });
                    },
                    borderRadius: BorderRadius.circular(20),
                    child: Padding(
                      padding: const EdgeInsets.all(2),
                      child: Icon(
                        _showAllHours
                            ? Icons.keyboard_arrow_up
                            : Icons.keyboard_arrow_down,
                        size: 25,
                        color: const Color(0xFF033B63),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),

        if (_showAllHours)
          Padding(
            padding: const EdgeInsets.only(
              left: 30,
              top: 12,
            ),
            child: Table(
              columnWidths: const {
                0: IntrinsicColumnWidth(), 
                1: FixedColumnWidth(12),   
                2: FlexColumnWidth(),      
              },
              children: parsedHours.map((item) {
                final isToday = item['day']!.toLowerCase().contains(currentDayKey);
                return TableRow(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Text(
                        item['day']!,
                        style: TextStyle(
                          fontFamily: 'Raleway',
                          fontSize: 14,
                          fontWeight: isToday ? FontWeight.bold : FontWeight.w600,
                          color: isToday ? const Color(0xFF033B63) : Colors.black87,
                        ),
                      ),
                    ),
                    const SizedBox(),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Builder(
                        builder: (context) {
                          final ranges = _extractTimeRanges(item['time']!);
                          final lines = ranges.isNotEmpty
                              ? ranges
                              : [item['time']!.trim()];

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: lines
                                .map(
                                  (interval) => Padding(
                                    padding: const EdgeInsets.only(bottom: 2),
                                    child: Text(
                                      interval,
                                      style: TextStyle(
                                        fontFamily: 'Raleway',
                                        fontSize: 14,
                                        fontWeight: isToday
                                            ? FontWeight.bold
                                            : FontWeight.normal,
                                        color: isToday
                                            ? const Color(0xFF033B63)
                                            : Colors.black87,
                                      ),
                                    ),
                                  ),
                                )
                                .toList(),
                          );
                        },
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
      ],
    );
  }

  Future<void> _openMaps() async {
    final mapsLink = widget.place.mapsLink.trim();

    if (mapsLink.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Link do mapa não cadastrado para este local.'),
        ),
      );
      return;
    }

    final uri = Uri.tryParse(mapsLink);

    if (uri == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Link do mapa inválido.'),
        ),
      );
      return;
    }

    try {
      final opened = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );

      if (!opened && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Não foi possível abrir o mapa.'),
          ),
        );
      }
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Não foi possível abrir o mapa.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final images = widget.place.imageAssets;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // FOTOS
                  Stack(
                    children: [
                      SizedBox(
                        height: 350,
                        width: double.infinity,
                        child: PageView.builder(
                          controller: _imageController,
                          itemCount: images.length,
                          onPageChanged: (index) {
                            setState(() {
                              _currentImageIndex = index;
                            });
                          },
                          itemBuilder: (context, index) {
                            return Image.asset(
                              images[index],
                              width: double.infinity,
                              height: 350,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  color: const Color(0xFFE8F0F7),
                                  alignment: Alignment.center,
                                  child: const Text(
                                    'Imagem não encontrada',
                                    style: TextStyle(
                                      fontFamily: 'Raleway',
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF466A99),
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                        ),
                      ),

                      // BOTÃO VOLTAR
                      Positioned(
                        top: 16,
                        left: 20,
                        child: GestureDetector(
                          onTap: () {
                            Navigator.pop(context);
                          },
                          child: Image.asset(
                            'assets/icons/navigation/back_icon.png',
                            width: 40,
                            height: 40,
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                width: 40,
                                height: 40,
                                decoration: const BoxDecoration(
                                  color: Color(0xFFDCEAF5),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.arrow_back_ios_new,
                                  size: 18,
                                  color: Color(0xFF033B63),
                                ),
                              );
                            },
                          ),
                        ),
                      ),

                      // CONTADOR DE FOTOS
                      if (images.isNotEmpty)
                        Positioned(
                          bottom: 16,
                          right: 16,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.4),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '${_currentImageIndex + 1}/${images.length}',
                              style: const TextStyle(
                                fontFamily: 'Raleway',
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),

                  const SizedBox(height: 18),

                  // CARD DE AVALIAÇÃO
                  Container(
                    width: 335,
                    height: 74,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: const Color(0xFFDCDCDC),
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                '${widget.place.rating}',
                                style: const TextStyle(
                                  fontFamily: 'Raleway',
                                  fontSize: 20,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Image.asset(
                                'assets/images/elderly/five_stars_rating.png',
                                width: 62,
                              ),
                            ],
                          ),
                        ),
                        if (widget.place.category.isNotEmpty) ...[
                          Container(
                            width: 1,
                            height: 42,
                            color: const Color(0xFFE5E5E5),
                          ),
                          Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  _iconForCategory(widget.place.category),
                                  size: 22,
                                  color: const Color(0xFF033B63),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _displayCategory(widget.place.category),
                                  style: const TextStyle(
                                    fontFamily: 'Raleway',
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),

                  const SizedBox(height: 18),

                  // CARD DE INFORMAÇÕES
                  Container(
                    width: 335,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: const Color(0xFFDCDCDC),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 20,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.place.name,
                            style: const TextStyle(
                              fontFamily: 'Quicksand',
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            widget.place.description,
                            style: const TextStyle(
                              fontFamily: 'Raleway',
                              fontSize: 16,
                              height: 1.45,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 22),
                          const Text(
                            'Horário de Funcionamento:',
                            style: TextStyle(
                              fontFamily: 'Quicksand',
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 8),
                          _buildOperatingHours(),
                          const SizedBox(height: 20),
                          const Text(
                            'Endereço:',
                            style: TextStyle(
                              fontFamily: 'Quicksand',
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Image.asset(
                                'assets/images/elderly/location.png',
                                width: 20,
                                height: 20,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  widget.place.address,
                                  style: const TextStyle(
                                    fontFamily: 'Raleway',
                                    fontSize: 16,
                                    height: 1.4,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 26),

                  // BOTÃO VER NO MAPA
                  SizedBox(
                    width: 170,
                    height: 46,
                    child: ElevatedButton(
                      onPressed: _openMaps,
                      style: ElevatedButton.styleFrom(
                        elevation: 0,
                        backgroundColor: const Color(0xFF003C6A),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: const Text(
                        'Ver no Mapa',
                        style: TextStyle(
                          fontFamily: 'Raleway',
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),

          // RODAPÉ PADRÃO
          const CustomFooter(
            currentIndex: 1,
          ),
        ],
      ),
    );
  }
}