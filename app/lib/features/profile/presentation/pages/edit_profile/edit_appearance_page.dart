import 'package:flutter/material.dart';

class EditAppearancePage extends StatefulWidget {
  const EditAppearancePage({super.key});

  @override
  State<EditAppearancePage> createState() => _EditAppearancePageState();
}

class _EditAppearancePageState extends State<EditAppearancePage> {
  double _fontSizeFactor = 1.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Color(0xFF0D3B66)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Aparência', style: TextStyle(fontFamily: 'Raleway', fontWeight: FontWeight.bold, color: Color(0xFF0D3B66))),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              decoration: BoxDecoration(color: const Color(0xFF4A729F), borderRadius: BorderRadius.circular(16)),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: const [
                      Text('Aa', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                      Text('Aa', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                      Text('Aa', style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  Row(
                    children: [
                      const Icon(Icons.remove, color: Colors.white),
                      Expanded(
                        child: Slider(
                          value: _fontSizeFactor,
                          min: 0.8,
                          max: 1.4,
                          activeColor: Colors.white,
                          inactiveColor: Colors.white54,
                          onChanged: (val) => setState(() => _fontSizeFactor = val),
                        ),
                      ),
                      const Icon(Icons.add, color: Colors.white),
                    ],
                  )
                ],
              ),
            ),
            const SizedBox(height: 24),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: const Color(0xFFF7F7F7), borderRadius: BorderRadius.circular(16)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: const [
                      Icon(Icons.visibility, color: Color(0xFF0D3B66)),
                      SizedBox(width: 8),
                      Text('Pré-visualização', style: TextStyle(fontFamily: 'Raleway', fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0D3B66))),
                    ],
                  ),
                  const Divider(height: 20, color: Colors.grey),
                  const SizedBox(height: 20),
                  Center(
                    child: Text(
                      'ABC abc 123',
                      style: TextStyle(fontFamily: 'Raleway', fontSize: 20 * _fontSizeFactor, fontWeight: FontWeight.bold, color: const Color(0xFF333333)),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF003B5C), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                onPressed: () => Navigator.pop(context),
                child: const Text('Aplicar', style: TextStyle(fontFamily: 'Raleway', fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}