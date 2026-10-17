# 🧪 2D Virtual Chemistry Lab

An interactive, Flutter-based educational simulator designed to visualize chemical reactions in a 2D virtual laboratory. 

## 🎯 Project Overview
The 2D Virtual Chemistry Lab provides students and educators with a safe, visual environment to mix chemicals, observe real-time reactions, and learn chemistry interactively. It features a curated database of verified reactions with accurate colors, precipitates, gas evolution, and heat effects.

### ✨ Key Features
- **Realistic Chemistry Engine**: Built on a verified dataset of chemical reactions, including accurate precipitate colors, gas evolution, and thermodynamic effects.
- **Dynamic Visuals**: Features real-time fluid animations, custom blast physics, and reaction-specific screen flashes.
- **Extensive Chemical Inventory**: 75+ chemicals with detailed properties, safety hazards, and molar masses.
- **Interactive Lab Bench**: Drag and drop chemicals, heat substances, test with litmus/pH paper, and observe reactions.

## 🛠️ Technical Stack & Architecture
- **Framework**: Flutter (Dart)
- **Platform**: Windows (Primary), Android-ready
- **Architecture**: Clean Architecture (Data, Domain, Presentation layers)
- **State Management**: Provider/Stateful widgets with optimized animation controllers.
- **Custom Graphics**: Utilizes Flutter's `CustomPainter` for high-performance, real-time 2D animations (flames, liquid physics, shockwaves).

## 🧪 Scientific Accuracy Disclaimer
This application is an **educational visual simulator**. While the chemical data (products, colors, and precipitates) is curated from standard chemical references, the physics and fluid dynamics are visual approximations designed for educational impact. The app is intended to supplement, not replace, physical laboratory experience.

## 🚀 Getting Started
1. Clone the repository:
   ```bash
   git clone https://github.com/malikqasim223/2D_virtual_chem_lab.git
   ```
2. Navigate to the project directory:
   ```bash
   cd 2D_virtual_chem_lab
   ```
3. Get dependencies:
   ```bash
   flutter pub get
   ```
4. Run the application:
   ```bash
   flutter run -d windows
   ```

## 📊 Audit & Verification
This project has undergone a preliminary structural and data audit.
- `flutter analyze`: **0 Errors**
- Automated data catalogs (CSV/JSON) are available for independent verification.

## 👨‍💻 Developer
**Malik Qasim**
*Final Year Project (FYP)*

---
*Built with ❤️ using Flutter.*
