// CONFIGURACION DE SPONSORS (la unica pieza que se toca para agregar, quitar o cambiar marcas).
// 1) Guardar el logo en la carpeta web/assets/sponsors/ (PNG con fondo transparente, ideal 300 a 600 px, menos de 60 KB).
// 2) Agregar o editar una linea en top o bottom con el nombre del archivo.
// 3) Subir los cambios con git; Vercel publica solo.
window.SPONSORS = {
  // Encabezado: sponsors oficiales (maximo 4; se ven a la derecha del titulo).
  top: [
    { name: 'YPF Autosur', logo: '', url: '' },
    { name: 'BGH',         logo: 'assets/sponsors/BGH.png', url: '' },
    { name: 'RGA',         logo: 'assets/sponsors/RGA.png', url: '' },
    { name: 'Tolhuin',     logo: '', url: '' },
  ],

  // Antes del pie de pagina. size define el tamaño (y el valor comercial) del espacio:
  //   'l' = principal (grande) · 'm' = destacado (mediano) · 's' = colaborador (chico)
  bottomTitle: 'Nos acompañan',
  bottom: [
    { name: 'Sublime Design', logo: 'assets/sponsors/sublime-design.png', url: 'https://www.instagram.com/sublime.tdf/', size: 'l' },
    { name: 'Somos',          logo: 'assets/sponsors/SOMOS.png',          url: '', size: 'm' },
    { name: 'Terra Ignis',     logo: 'assets/sponsors/TERRA IGNIS.png',    url: '', size: 's' },
  ],

  // Cantidad de espacios que se muestran por tamaño. Los que no tienen sponsor aparecen como "Tu marca acá"
  showPlaceholders: true,
  slots: { l: 2, m: 4, s: 6 },
};
