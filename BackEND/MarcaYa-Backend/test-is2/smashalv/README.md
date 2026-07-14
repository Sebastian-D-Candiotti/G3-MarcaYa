# Pruebas IS2 - Jose Fabrizzio Bustillos Rivera

Esta carpeta centraliza en `main` las pruebas de las historias desarrolladas y auditadas por Jose Fabrizzio Bustillos Rivera para MarcaYA Release 2.

## Contenido

| Historia | Backend Rails | Frontend Flutter | Estado |
|---|---|---|---|
| US-NUEVA-10 | `us_nueva_10/` | `FrontEND/MarcaYa/test-is2/jose_fabrizzio_bustillos_rivera/us_nueva_10/` | Pruebas disponibles |
| US-NUEVA-15 | `us_nueva_15/` | `FrontEND/MarcaYa/test-is2/jose_fabrizzio_bustillos_rivera/us_nueva_15/` | Pruebas disponibles |
| US-NUEVA-02 / HU3 | `us_nueva_02/README.md` | No existe implementacion para probar | No ejecutada |
| US-NUEVA-16 | `us_nueva_16/` | `FrontEND/MarcaYa/test-is2/jose_fabrizzio_bustillos_rivera/us_nueva_16/` | Pruebas disponibles |

Las matrices, resultados, defectos y casos de caja negra estan en `evidencias/`. Las pruebas estructurales adicionales estan documentadas en `PRUEBAS_CAJA_BLANCA.md`. El informe general esta en `INFORME_CONSOLIDADO_QA_RELEASE_2.md` y la ejecucion realizada directamente sobre `main` esta en `RESULTADOS_EJECUCION_MAIN.md`.

## Ejecutar backend

Desde `BackEND/MarcaYa-Backend` y usando exclusivamente la base de test:

```powershell
$env:RAILS_ENV = "test"
bin/rails test test-is2/smashalv/us_nueva_10
bin/rails test test-is2/smashalv/us_nueva_15
bin/rails test test-is2/smashalv/us_nueva_16
bin/rails test test-is2/smashalv/us_nueva_10/verificar_cuenta_caja_blanca_test.rb `
  test-is2/smashalv/us_nueva_15/sincronizar_marcaciones_offline_caja_blanca_test.rb
```

## Ejecutar frontend

Desde `FrontEND/MarcaYa`:

```powershell
flutter pub get
flutter test test-is2/jose_fabrizzio_bustillos_rivera
```

## Origen verificable

| Historia | Commit QA de origen |
|---|---|
| US-NUEVA-10 | `4e778284bb95ed2f4eb09212d1f36476777e34be` |
| US-NUEVA-15 | `985bba388619293814640a5bc3b27ab895eebabd` |
| US-NUEVA-02 | `75deff72794987cbe0a3be7271d0775e181d3db8` |
| US-NUEVA-16 | `60d7b738a65e9f69069ac11e61ec92e3dde5fde4` |

Las pruebas Rails cargan `test/test_helper.rb` mediante el helper local de esta carpeta. Las pruebas Flutter permanecen dentro del proyecto Flutter para conservar la resolucion correcta del paquete `marcapp`.
