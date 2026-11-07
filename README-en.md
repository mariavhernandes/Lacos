| [Português 🇧🇷](README.md) | [English 🇺🇸](README-en.md) |
| ------------------------------------------------- | -------------------------------------------------- |

# Laços - Social Connection and Interaction

## 📌 About the Project

**Laços** is a project developed to encourage social interaction and help reduce social isolation among older adults. Its purpose is to provide an accessible digital platform that makes it easier to discover activities, build connections, and communicate with people who share similar interests.

The application allows users to discover places and activities based on their interests, connect with others, participate in groups, and chat with other users. It also includes features for linked family members or caregivers, allowing them to access certain monitoring resources.

The project also integrates **Internet of Things (IoT)** and **Artificial Intelligence (AI)** technologies, expanding opportunities for interaction and support. The IoT device enables image capture through a camera connected to an ESP32-S3 microcontroller, while the Laços Assistant uses generative artificial intelligence to provide answers and guidance to users.

## 🚀 Features

### 📱 Application

- **Registration and authentication:** Account creation, login, and password recovery.
- **Profile management:** Viewing and editing personal information.
- **Activity discovery:** Suggestions for places and activities based on users' interests.
- **Social interaction:** Connecting and chatting with other users.
- **Group creation:** Creating groups to encourage collective activities and social interaction.
- **Notifications:** Updates and interaction notifications.
- **Family member connection:** Linking a family member or caregiver account to the main user account, allowing access to specific monitoring features.

### 📷 Internet of Things (IoT)

The IoT module consists of a physical device developed with an **ESP32-S3** microcontroller and an **OV2640** camera. Its purpose is to capture images using a physical button, making the records available for viewing by the family member or caregiver linked to the account.

Its purpose is especially relevant in face-to-face situations where users may feel uncomfortable or find themselves in a potentially risky situation and wish to share records with their family members.

As a future proposal, a compact brooch-shaped device was designed, inspired by the Laços visual identity, to make everyday use easier.

<p align="center">
  <img width="400" alt="Laços IoT Device" src="https://github.com/user-attachments/assets/6fd38b62-71e6-4776-9c76-478a882e24f0" />
</p>

### 🤖 Artificial Intelligence (AI)

Artificial intelligence is integrated into the application through the **Laços Assistant**, a chatbot designed to provide information and guidance to users while they navigate the platform.

The assistant uses the **Gemini API**, which processes messages and generates responses in natural language. Its communication is designed to be clear, welcoming, and accessible to the target audience.

<p align="center">
  <img width="180" alt="Chatbot 1" src="https://github.com/user-attachments/assets/5bdfa4b3-1d8d-4e2a-a18c-424973adf626" />
  <img width="180" alt="Chatbot 2" src="https://github.com/user-attachments/assets/c7163dfb-0866-473f-93a0-3f50527acc20" />
  <img width="180" alt="Chatbot 3" src="https://github.com/user-attachments/assets/eea76f46-dcaa-49c7-8614-3878900c9886" />
</p>

## 🏗️ Architecture and Methodology

The development of Laços followed the **SDD (Spec-Driven Development)** approach.

The process was structured around requirements definition, specification development, feature breakdown into tasks, and implementation of the planned features. This approach helped keep the project organized, guide the team's activities, and facilitate the validation of implemented features.

The system architecture integrates different components:

- **Mobile application:** Developed with Flutter, responsible for the interfaces, navigation, and features available to users.
- **Data and authentication layer:** Uses Firebase Authentication and Cloud Firestore to manage accounts and application data.
- **Backend:** Developed in PHP, provides APIs for receiving and storing images from the IoT device and communicating with external services.
- **IoT device:** Consists of the ESP32-S3 and OV2640 camera, responsible for capturing and transmitting images to the backend.
- **Artificial Intelligence service:** Integrated into the backend through the Gemini API, responsible for processing messages and generating responses from the Laços Assistant.
- **Infrastructure:** Uses Docker for containerization and running backend services and development environments.

The integration of these components allows the application, physical device, and artificial intelligence services to work together as part of a unified solution.

## 🛠️ Technologies Used

| Technology | Application |
|---|---|
| **Flutter / Dart** | Mobile application development |
| **Firebase Authentication** | User authentication and account management |
| **Cloud Firestore** | Data storage and management |
| **PHP** | Backend and API development |
| **Docker** | Containerization and service management |
| **Gemini API** | Message processing and AI-generated responses |
| **C/C++ (Arduino)** | IoT device firmware development |
| **HTTP / REST API** | Communication and integration between components |

## 📸 Screenshots

### 👴🏻 Main User Interface

<p align="left">
  <img width="180" alt="Login" src="https://github.com/user-attachments/assets/bc56bf2b-52ed-40d1-aae0-0141f4a6ece3" />
  <img width="180" alt="Welcome" src="https://github.com/user-attachments/assets/5dfe058a-d840-4a25-9cd4-2ed47b1f6503" />
  <img width="180" alt="Home" src="https://github.com/user-attachments/assets/438ad2c2-5264-4bc2-a741-46ad34566a96" />
  <img width="180" alt="Places" src="https://github.com/user-attachments/assets/3edac756-5952-4f20-a806-0022c8d8d489" />
</p>

### 👩🏻 Family Member Interface

<p align="left">
  <img width="180" alt="Family Home" src="https://github.com/user-attachments/assets/0c12e1cd-1de3-4b1c-b4e7-1d22915730da" />
  <img width="180" alt="IoT Records" src="https://github.com/user-attachments/assets/7982f901-cd26-45fd-a108-1cf5680dfbca" />
  <img width="180" alt="Conversations" src="https://github.com/user-attachments/assets/210fec7b-f77d-42b4-9664-e1dcb36521ee" />
</p>
