// CONFIGURACION DE SPONSORS (la unica pieza que se toca para agregar, quitar o cambiar marcas).
// 1) Guardar el logo en la carpeta web/assets/sponsors/ (PNG con fondo transparente, ideal 300 a 600 px, menos de 60 KB).
// 2) Agregar o editar una linea en top o bottom con el nombre del archivo.
// 3) Subir los cambios con git; Vercel publica solo.
// CONFIGURACION DE SPONSORS
window.SPONSORS = {
  // Encabezado: sponsors oficiales (máximo 4)
  top: [
    { name: 'YPF Autosur', logo: 'assets/sponsors/YPF.png', url: '' },
    { name: 'BGH',         logo: 'assets/sponsors/BGH.png', url: '' },
    { name: 'SOMOS',       logo: 'assets/sponsors/SOMOS.png', url: '' },
    { name: 'RGA',         logo: 'assets/sponsors/RGA.png', url: '' },
  ],

  // Pie de página
  bottomTitle: 'NOS ACOMPAÑAN',
  bottom: [
    { name: 'TERRA IGNIS',     logo: 'assets/sponsors/TERRA IGNIS.png',    url: '', size: 'l' },
    { name: 'GRAPHIC DESIGN', logo: 'assets/sponsors/GRAPHIC DESIGN.png', url: '', size: 'l' },
    { name: 'SOMOS',          logo: 'assets/sponsors/SOMOS.png',          url: '', size: 'm' },
    { name: 'ELITEC',         logo: 'assets/sponsors/ELITEC.png',         url: '', size: 'm' },
    { name: 'MIGOFPV',        logo: 'assets/sponsors/MIGOFPV.png',        url: '', size: 'm' },
    { name: 'TOLHUIN',        logo: 'assets/sponsors/TOLHUIN.png',        url: '', size: 'm' },
    { name: 'DON ALDO',       logo: 'assets/sponsors/DON ALDO.png',       url: '', size: 's' },
    { name: 'PUNTA POPPER',   logo: 'assets/sponsors/PUNTA POPPER.png',   url: '', size: 's' },
    { name: 'JMF',            logo: 'assets/sponsors/JMF.png',            url: '', size: 's' },
    { name: 'RGA',            logo: 'assets/sponsors/RGA.png',            url: '', size: 's' },
    { name: 'BGH',            logo: 'assets/sponsors/BGH.png',            url: '', size: 's' },
    { name: 'YPF Autosur',    logo: 'assets/sponsors/YPF.png',            url: '', size: 's' },
  ],

  showPlaceholders: false,
  slots: { l: 2, m: 4, s: 6 },
};
