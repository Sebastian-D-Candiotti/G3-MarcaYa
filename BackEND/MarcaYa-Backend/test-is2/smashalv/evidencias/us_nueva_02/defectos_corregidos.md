# Defectos - US-NUEVA-02

## DEF-02-01 - Documentacion declara codigo inexistente

- Historia de usuario: US-NUEVA-02.
- Modulo: rama y trazabilidad.
- Descripcion: el TXT enumera modelos, casos de uso, endpoints, migraciones y tests que no existen en el arbol Git.
- Severidad: Alta.
- Precondiciones: checkout de `feature/HU3-Justificacion-de-tardanzas`.
- Pasos: ejecutar `git show --stat 2143536` y buscar los archivos declarados.
- Resultado esperado: codigo y pruebas versionados.
- Resultado obtenido: solo `docs/HU3-Jose-Bustillos.txt`.
- Causa raiz: el codigo no fue incluido en el commit/merge de la rama.
- Impacto: US-NUEVA-02 no puede probarse ni entregarse desde esta rama.
- Accion correctiva: se agrego advertencia QA al TXT; falta recuperar o implementar el codigo.
- Prueba de regresion: no aplicable hasta disponer de implementacion.
- Responsable: Jose Fabrizzio Bustillos Rivera.
- Estado final: Pendiente.
- Evidencia: commit 2143536 y merge 89c5c97 agregan un solo archivo.

| ID | Historia | Defecto | Severidad | Causa raiz | Accion correctiva | Prueba de regresion | Resultado final | Evidencia |
|---|---|---|---|---|---|---|---|---|
| DEF-02-01 | US-NUEVA-02 | Documentacion sin codigo asociado | Alta | Archivos no versionados | Advertencia QA; recuperar codigo | Pendiente | PENDIENTE | `git show --stat` |
