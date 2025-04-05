# Inventario ventas

## 📁 Estructura de Carpetas del Proyecto

A continuación se muestra la estructura principal del proyecto, esto para mantener el código organizado y modularizado:
´´
lib/
├── main.dart
├── core/                # Configuraciones generales
│   ├── database/        # Configuración de SQLite
│   ├── utils/           # Funciones auxiliares
│   └── constants.dart   # Constantes globales
├── models/              # Modelos de datos (Producto, Cliente, etc.)
├── services/            # Lógica de acceso a base de datos
├── ui/                  # Interfaz de usuario
│   ├── screens/         # Pantallas principales
│   └── widgets/         # Componentes reutilizables
└── providers/           # Gestión de estado (ej. Provider)
´´

