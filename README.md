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

### Ejecutar la aplicación

Para ejecutar la aplicación, siga los siguientes pasos:

1. Abra el proyecto en Android Studio o en VS Code.
2. Conecte su dispositivo Android a su computadora o inicie un emulador.
3. Seleccione su dispositivo desde el menú desplegable en la barra de herramientas.
4. Haga clic en el botón "Run" para ejecutar la aplicación en su dispositivo.

### Generar el archivo APK

El archivo APK se genera automáticamente a través de [GitHub Actions](https://github.com/features/actions) después de un despliegue y se puede encontrar en los [adjuntos de la versión](https://github.com/Ekisa-Team/xsighub_mobile/releases).

Actualmente se generan 5 archivos APK optimizados para diferentes arquitecturas:

```sh
xsighub-release-<versión>.apk # Universal
xsighub-arm64-v8a-release-<versión>.apk
xsighub-armeabi-v7a-release-<versión>.apk
xsighub-x86-release-<versión>.apk
xsighub-x86_64-release-<versión>.apk
```

El nombre de los archivos APK sigue la siguiente convención: `xsighub-{{abi}}-release-{{git_tag}}.apk` (e.g., `xsighub-arm64-v8a-release-v0.2.34.apk`).

### Realizar despliegue

Para desplegar una nueva versión de este proyecto, se deben seguir los siguientes pasos:

1. Ejecutar el script `./scripts/release.sh` y seguir las instrucciones para especificar el tipo de versión que desea publicar ("major", "minor" o "patch") y si desea agregar un alcance a la versión (por ejemplo, "alpha", "beta" o "stable").

2. Verificar que los cambios y la etiqueta de Git se hayan publicado correctamente en el repositorio remoto. Adicionalmente, debe haber un workflow generando los APKs y la nueva versión.

#### Sumatoria de acciones

El script `release.sh` es una herramienta que automatiza el proceso de publicar una nueva versión de este proyecto. El script realiza los siguientes pasos:

- Pide al usuario que especifique el tipo de versión que desea publicar y si desea agregar un alcance a la versión.
- Actualiza automáticamente el archivo pubspec.yaml con la nueva versión especificada.
- Crea automáticamente una etiqueta de Git con la nueva versión especificada.
- Crea automáticamente un commit con el mensaje "Bump version to [nueva versión]" y sube los cambios al repositorio remoto.
- Sube la etiqueta de Git al repositorio remoto.
- Una vez que la etiqueta ha sido subida, el pipeline de GitHub Actions se encargará de generar automáticamente los APKs para la nueva versión.

> **Note**
> Asegúrese de darle permisos de ejecución al script (`chmod +x .scripts/release.sh`)

> **Note**
> Si es un usuario de Windows, necesitará instalar un shell de Bash en su sistema antes de poder ejecutar el script. Otra opción es utilizar Windows Subsystem for Linux (WSL).

### Recursos adicionales

- [Documentación de Flutter](https://flutter.dev/docs)
- [Catálogo de widgets de Flutter](https://flutter.dev/docs/development/ui/widgets)
- [Ejemplos y demos de Flutter](https://flutter.dev/docs/cookbook)

### Aplicación complementaria

También se dispone de una aplicación complementaria que permite transferir, almacenar y gestionar las firmas de los usuarios en el Sistema Hub. Para obtener más información sobre esta aplicación, [visite este enlace](https://github.com/Ekisa-Team/xsighub).
