# Pruebas unitarias - US-NUEVA-16

| ID | Historia | Componente aislado | Escenario | Dependencias simuladas | Resultado esperado | Resultado obtenido | Estado |
|---|---|---|---|---|---|---|---|
| UT-16-01 | US-NUEVA-16 | Informes Base | Tipos admitidos/no admitidos | Ninguna | Solo DIARIO/SEMANAL/MENSUAL | Coincide | APROBADA |
| UT-16-02 | US-NUEVA-16 | Informes Base | Limites diarios/semanales/mensuales | Fechas fijas | Reglas exactas | Coincide | APROBADA |
| UT-16-03 | US-NUEVA-16 | Informes Base | Fecha no ISO y rango invertido | Ninguna | ArgumentError | Coincide | APROBADA |
| UT-16-04 | US-NUEVA-16 | InformeAsistenciaRecord | Actualizar/eliminar cerrado | PostgreSQL test | Operacion abortada | Coincide | APROBADA |
| UT-16-05 | US-NUEVA-16 | InformeAsistenciaRecord | Fin anterior a inicio | PostgreSQL test | Modelo invalido | Coincide | APROBADA |
| UT-16-06 | US-NUEVA-16 | AsistenciaPdfService | Texto con tildes y reporte vacio | Struct de informe | PDF 1.4 con UTF-16 | Coincide | APROBADA |
| UT-16-07 | US-NUEVA-16 | AsistenciaPdfService | 100 empleados | Struct de informe | Mas de una pagina | Coincide | APROBADA |
| UT-16-08 | US-NUEVA-16 | InformesAsistenciaProvider | Historial | Cliente HTTP fake | Loading y parseo | Coincide | APROBADA |
| UT-16-09 | US-NUEVA-16 | InformesAsistenciaProvider | Error de preview | Cliente HTTP fake | Error visible | Coincide | APROBADA |
| UT-16-10 | US-NUEVA-16 | InformesAsistenciaProvider | PDF y cierre | Cliente HTTP fake | Bytes/nombre y refresco | Coincide | APROBADA |
