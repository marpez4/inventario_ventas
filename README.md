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
| nombre        | TEXT     | Nombre de la sucursal                    |
| ubicacion     | TEXT     | Ubicación o dirección de la sucursal     |

---

### 📦 Tabla: `producto`

| Campo         | Tipo     | Descripción                                  |
|---------------|----------|----------------------------------------------|
| id            | INTEGER  | Clave primaria, autoincremental              |
| nombre        | TEXT     | Nombre del producto                          |
| descripcion   | TEXT     | Descripción                                  |
| precio        | REAL     | Precio unitario                              |
| id_sucursal   | INTEGER  | FK a `sucursal`                              |
| stock         | INTEGER  | Cantidad disponible                          |


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
| nombre      | TEXT     | Nombre de usuario                             |
| correo      | TEXT     | Correo del usuario                            |
| contrasena  | TEXT     | Contraseña                                    |
| rol         | TEXT     | Rol del usuario ( `admin`, `vendedor`)        |

---

### 🧾 Tabla: `venta`

| Campo         | Tipo     | Descripción                                                |
|---------------|----------|------------------------------------------------------------|
| id            | INTEGER  | Clave primaria                                             |
| fecha         | TEXT     | Fecha y hora de la venta                                   |
| id_sucursal   | INTEGER  | FK a `sucursal`                                            |
| id_cliente    | INTEGER  | FK a `cliente`                                             |
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

---

### 🔗 Relaciones clave entre tablas

- Una `sucursal` tiene muchos `productos` y muchas `ventas`.
- Un `producto` puede aparecer en muchas `ventas`, y cada `venta` puede tener muchos `productos` (relación a través de `detalle_venta`).
- Una `venta` puede o no estar ligada a un `cliente`.
- Un `usuario` accede a la app, pero no es estrictamente necesario relacionarlo con cada venta.

---


## 👥 Usuarios por Defecto

Al iniciar por primera vez la aplicación, el sistema crea automáticamente dos usuarios predefinidos para facilitar las pruebas de login y control de acceso.

| Nombre           | Rol       | Correo             | Contraseña     |
|------------------|-----------|--------------------|----------------|
| Admin Principal  | admin     | admin@iv.com     | admin123       |
| Vendedor Uno     | vendedor  | vendedor@iv.com  | vendedor123    |

### 🚀 Control de Acceso por Roles

- **Admin** tiene acceso completo a todos los módulos: sucursales, productos, ventas, clientes, usuarios, reportes.
- **Vendedor** solo tiene acceso a funciones básicas como gestión de clientes, registrar ventas y consultar información.

### 🛠 ¿Cómo se crean?

> Estos usuarios se insertan automáticamente en la base de datos local (SQLite) cuando se genera por primera vez, en el método `_onCreate()` de `DatabaseHelper`.


### ⚙️ Procesos de Venta y Simulación de Pago

El sistema sigue el siguiente flujo para registrar una venta:

1. Selección de sucursal donde ocurre la venta.

2. Selección de cliente.

3. Selección del método de pago (Efectivo, Tarjeta o PayPal).

4. Selección de productos disponibles en la sucursal (solo productos en stock).

5. Visualización automática del total de la venta conforme se agregan productos.

6. Simulación de pago:

   - Antes de registrar la venta se muestra un diálogo que simula el procesamiento del pago durante unos segundos.

   - Se muestra el método de pago seleccionado y el total.

7. Registro de venta exitoso:

    - Se guardan los detalles de la venta en la base de datos.

    - Se actualiza el inventario descontando el stock de cada producto vendido.

> El pago simulado no utiliza pasarelas externas y no maneja información sensible.

### 📊Módulo de Reportes
El sistema implementa dos reportes básicos, accesibles desde el menú principal:

📈 Reporte de Ventas
- Muestra la lista de todas las ventas registradas.

- Permite filtrar las ventas por:

    - Sucursal

    - Rango de fechas

- Muestra:

    - Fecha de venta

    - Sucursal

    - Cliente

    - Método de pago

    - Productos vendidos

    - Total de la venta

- Visualización en tarjetas (Cards) limpias con ExpansionTile.

### 📦 Reporte de Inventario
- Muestra los productos agrupados por sucursal.

- Para cada producto se visualiza:

  - Nombre

  - Descripción

  - Precio

  - Stock disponible

- Los productos con stock bajo (≤5) se destacan en color rojo para alertar al usuario.

- Visualización en tarjetas modernas.