# Xsighub_mobile

📱 Aplicación móvil que se conecta al sistema Hub y registra las firmas de los usuarios.

## Cómo empezar

Este proyecto es una aplicación Flutter y actualmente solo soporta la plataforma Android. Para comenzar con el proyecto, se requiere lo siguiente:

### Requisitos previos

- Se debe tener instalado Flutter en el equipo. Puede encontrar las instrucciones de instalación [aquí](https://flutter.dev/docs/get-started/install).
- Si no ha instalado Android Studio, asegúrese de instalarlo y configurar su entorno de desarrollo de Android. Puede encontrar las instrucciones de instalación [aquí](https://developer.android.com/studio/install).
- Si va a utilizar VS Code, asegúrese de instalar la extensión de Dart y Flutter. Puede encontrar la extensión [aquí](https://marketplace.visualstudio.com/items?itemName=Dart-Code.flutter).

### Clonar el repositorio

```sh
git clone https://github.com/Ekisa-Team/xsighub_mobile.git
```

### Configuración

Este proyecto utiliza trunk-based development para el control de versiones y el proceso de despliegue. Trunk-based development es un enfoque de desarrollo que implica la integración continua de cambios en una única rama principal, conocida como el tronco. Para obtener más información sobre trunk-based development, puede visitar este [enlace](https://trunkbaseddevelopment.com/).

Para comenzar a trabajar en una nueva característica, se deben seguir los siguientes pasos:

1. Asegúrese de que se encuentra en la rama principal:

   ```sh
   git checkout main
   ```

2. Cree una nueva rama a partir de la rama develop con el siguiente comando:

   ```sh
   git checkout -b nombre-de-la-rama
   ```

3. Desarrolle y pruebe su nueva característica en la rama recién creada.

4. Una vez que la característica está lista, haga una [solicitud de extracción (pull request)](https://docs.github.com/en/pull-requests/collaborating-with-pull-requests/proposing-changes-to-your-work-with-pull-requests/about-pull-requests) para integrar los cambios en la rama principal.

5. Si es necesario, haga ajustes en la característica y repita el proceso de revisión y solicitud de extracción.

Para realizar un depliegue, siga estos pasos:

1. Asegúrese de que la rama principal está actualizada y estable.

   ```sh
   git checkout main
   git pull origin main
   ```

2. Cree un nuevo tag para marcar el despliegue.

   ```sh
   git tag v0.0.0
   ```

3. Suba el tag al repositorio remoto.

   ```sh
   git push origin v0.0.0
   ```

### Ejecutar la aplicación

Para ejecutar la aplicación, siga los siguientes pasos:

1. Abra el proyecto en Android Studio o en VS Code.
2. Conecte su dispositivo Android a su computadora o inicie un emulador.
3. Seleccione su dispositivo desde el menú desplegable en la barra de herramientas.
4. Haga clic en el botón "Run" para ejecutar la aplicación en su dispositivo.

### Generar el archivo APK

El archivo APK se genera automáticamente a través de [GitHub Actions](https://github.com/features/actions) después de un despliegue y se puede encontrar en los [adjuntos de la versión](https://github.com/Ekisa-Team/xsighub_mobile/releases).

Actualmente se generan 3 archivos APK optimizados para diferentes arquitecturas:

- **armeabi-v7a**: Esta es la arquitectura de procesador más común para dispositivos Android. Lo utilizan dispositivos con CPU ARMv7, que se encuentran en la mayoría de los teléfonos inteligentes y tabletas con Android lanzados en los últimos 10 años.

- **arm64-v8a**: Esta es la versión de 64 bits de la arquitectura ARM, utilizada por los dispositivos Android más nuevos con CPU ARMv8.

- **x86_64**: Esta es la versión de 64 bits de la arquitectura x86, utilizada por algunos dispositivos Android con CPU Intel o AMD.

El nombre de los archivos APK sigue la siguiente convención: `xsighub-{{abi}}-release-{{git_tag}}.apk` (e.g., `xsighub-arm64-v8a-release-v0.2.34.apk`).

### Recursos adicionales

- [Documentación de Flutter](https://flutter.dev/docs)
- [Catálogo de widgets de Flutter](https://flutter.dev/docs/development/ui/widgets)
- [Ejemplos y demos de Flutter](https://flutter.dev/docs/cookbook)

### Aplicación complementaria

También se dispone de una aplicación complementaria que permite transferir, almacenar y gestionar las firmas de los usuarios en el Sistema Hub. Para obtener más información sobre esta aplicación, [visite este enlace](https://github.com/Ekisa-Team/xsighub).
