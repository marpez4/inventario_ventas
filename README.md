# Inventario ventas

## 📁 Estructura de Carpetas del Proyecto

A continuación se muestra la estructura principal del proyecto, esto para mantener el código organizado y modularizado:

````markdown
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
````

## 📚 Dependencias del Proyecto

A continuación se describen las dependencias utilizadas en el archivo `pubspec.yaml` del proyecto:

```yaml
dependencies:
  flutter:
    sdk: flutter
  sqflite: ^2.3.0
  path: ^1.8.3
  provider: ^6.1.2
  intl: ^0.18.1

dev_dependencies:
  flutter_lints: ^3.0.0
```

## 📦 Descripción de cada paquete

flutter: SDK base para desarrollar aplicaciones móviles multiplataforma con Flutter.

sqflite: Permite el uso de una base de datos SQLite local dentro de la aplicación. Es utilizado para crear, leer, actualizar y eliminar datos persistentemente en el dispositivo.

path: Proporciona funciones para manipular rutas de archivos, muy útil en combinación con sqflite para ubicar la base de datos en el dispositivo.

provider: Biblioteca para la gestión de estado de la aplicación. Facilita el acceso y actualización de datos compartidos entre pantallas o widgets de manera reactiva y limpia.

intl: Soporte para internacionalización y manejo de fechas, tiempos y formatos numéricos. Se usa comúnmente para formatear fechas en reportes o interfaces.

flutter_lints: Conjunto de reglas de estilo y buenas prácticas para mantener el código limpio y consistente durante el desarrollo.


## 🗄️ Diseño de la Base de Datos (SQLite)

La base de datos local utiliza SQLite y se estructura con las siguientes tablas para representar el modelo de negocio del sistema de ventas e inventario multi-sucursal.

### 📍 Tabla: `sucursal`

| Campo         | Tipo     | Descripción                              |
|---------------|----------|------------------------------------------|
| id            | INTEGER  | Clave primaria, autoincremental          |
| nombre        | TEXT     | Nombre de la sucursal (obligatorio)      |
| ubicacion     | TEXT     | Ubicación o dirección de la sucursal     |

---

### 📦 Tabla: `producto`

| Campo         | Tipo     | Descripción                                  |
|---------------|----------|----------------------------------------------|
| id            | INTEGER  | Clave primaria, autoincremental              |
| nombre        | TEXT     | Nombre del producto                          |
| descripcion   | TEXT     | Descripción opcional                         |
| precio        | REAL     | Precio unitario                              |
| id_sucursal   | INTEGER  | FK a `sucursal`                              |
| stock         | INTEGER  | Cantidad disponible en esa sucursal          |


---

### 📊 Tabla: `inventario` (opcional, si no usas `stock` en `producto`)

| Campo           | Tipo     | Descripción                                       |
|-----------------|----------|---------------------------------------------------|
| id_sucursal     | INTEGER  | FK a `sucursal`                                   |
| id_producto     | INTEGER  | FK a `producto`                                   |
| cantidad        | INTEGER  | Stock del producto en esa sucursal               |

> 🔑 Clave primaria compuesta: `(id_sucursal, id_producto)`

---

### 👤 Tabla: `cliente`

| Campo       | Tipo     | Descripción                          |
|-------------|----------|--------------------------------------|
| id          | INTEGER  | Clave primaria, autoincremental      |
| nombre      | TEXT     | Nombre del cliente                   |
| correo      | TEXT     | Correo electrónico del cliente       |

---

### 🧑‍💻 Tabla: `usuario`

| Campo       | Tipo     | Descripción                                   |
|-------------|----------|-----------------------------------------------|
| id          | INTEGER  | Clave primaria, autoincremental               |
| nombre      | TEXT     | Nombre o nickname de usuario                  |
| correo      | TEXT     | Correo del usuario (opcional)                 |
| contrasena  | TEXT     | Contraseña (puede estar en texto plano)       |
| rol         | TEXT     | Rol del usuario (ej: `admin`, `vendedor`)     |

---

### 🧾 Tabla: `venta`

| Campo         | Tipo     | Descripción                                                |
|---------------|----------|------------------------------------------------------------|
| id            | INTEGER  | Clave primaria                                             |
| fecha         | TEXT     | Fecha y hora de la venta                                   |
| id_sucursal   | INTEGER  | FK a `sucursal`                                            |
| id_cliente    | INTEGER  | FK a `cliente` (puede ser `NULL` si es venta sin cliente)  |
| metodo_pago   | TEXT     | Texto indicando método (Efectivo, Tarjeta, etc.)           |
| total         | REAL     | Total de la venta                                          |

---

### 📋 Tabla: `detalle_venta`

| Campo           | Tipo     | Descripción                                         |
|-----------------|----------|-----------------------------------------------------|
| id              | INTEGER  | Clave primaria                                      |
| id_venta        | INTEGER  | FK a `venta`                                        |
| id_producto     | INTEGER  | FK a `producto`                                     |
| cantidad        | INTEGER  | Cantidad de ese producto vendido                    |
| precio_unitario | REAL     | Precio del producto al momento de la venta          |

> 🔗 Esta tabla permite una relación muchos a muchos entre `venta` y `producto`.

---

### 🔗 Relaciones clave entre tablas

- Una `sucursal` tiene muchos `productos` y muchas `ventas`.
- Un `producto` puede aparecer en muchas `ventas`, y cada `venta` puede tener muchos `productos` (relación a través de `detalle_venta`).
- Una `venta` puede o no estar ligada a un `cliente`.
- Un `usuario` accede a la app, pero no es estrictamente necesario relacionarlo con cada venta.

---


