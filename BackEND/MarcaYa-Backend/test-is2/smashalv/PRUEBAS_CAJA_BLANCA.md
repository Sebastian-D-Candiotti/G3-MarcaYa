# Pruebas de caja blanca - Jose Fabrizzio Bustillos Rivera

Fecha de ejecucion: 2026-07-13 (America/Lima).

## Fuente y criterio aplicado

Este documento sigue el formato del capitulo 10.2 del informe `MARCAYA release 2_2026_1 (1).pdf`, paginas 295 a 299. El informe solicita identificar condiciones, calcular la complejidad ciclomatica con `V(G) = numero de decisiones + 1`, definir caminos independientes y registrar el resultado obtenido.

El informe asigna como minimo caja negra y defectos corregidos a Jose Fabrizzio Bustillos Rivera. Esta entrega agrega caja blanca como evidencia adicional sobre el codigo fuente disponible en `main`.

## Alcance

| Historia | Modulo | Codigo evaluado | Estado |
|---|---|---|---|
| US-NUEVA-10 | Verificacion de cuenta por correo | `Application::UseCases::Auth::VerificarCuenta` | Evaluado |
| US-NUEVA-15 | Sincronizacion offline | `Application::UseCases::Asistencias::SincronizarMarcacionesOffline` | Evaluado |
| US-NUEVA-02 / HU3 | Justificaciones | No existe caso de uso, endpoint ni modelo de justificaciones en `main` | No evaluable |

No se modifico codigo productivo. Se usaron repositorios y servicios falsos para controlar cada condicion interna sin correo, GPS ni red reales.

## 10.2.3 Prueba de caja blanca: verificacion de cuenta

- **Responsable:** Jose Fabrizzio Bustillos Rivera
- **Modulo evaluado:** Verificacion de cuenta por correo
- **Clase evaluada:** `app/application/use_cases/auth/verificar_cuenta.rb`
- **Metodo evaluado:** `#ejecutar`, incluyendo `#validar_parametros!` y `#codigo_vencido?`

### Descripcion del metodo evaluado

Valida correo y codigo, busca al usuario, impide reutilizar una verificacion, comprueba la expiracion y compara el codigo con su digest. Solo el camino exitoso crea y guarda un usuario en estado `ACTIVO`, consume el digest y registra `verificado_en`.

### Pseudocodigo evaluado

```text
validar correo obligatorio y codigo obligatorio
validar codigo numerico de 6 digitos
buscar usuario; fallar si no existe
fallar si ya esta verificado
fallar si la expiracion es nula o expiro
fallar si el codigo no coincide con el digest
activar, consumir codigo y guardar usuario
```

### Condiciones evaluadas

| Condicion | Descripcion | Resultado posible |
|---|---|---|
| C1 | Correo vacio | Si / No |
| C2 | Codigo vacio, segundo operando del `||` | Si / No |
| C3 | Codigo cumple `\A\d{6}\z` | Si / No |
| C4 | Usuario encontrado | Si / No |
| C5 | Usuario ya verificado | Si / No |
| C6 | Expiracion nula, primer operando del `||` | Si / No |
| C7 | Expiracion menor o igual al reloj | Si / No |
| C8 | Codigo coincide con el digest | Si / No |

### Complejidad ciclomatica

- Formula: `V(G) = numero de decisiones + 1`.
- Decisiones identificadas: 8.
- `V(G) = 8 + 1 = 9`.
- Los operandos con cortocircuito se cuentan individualmente, igual que en el ejemplo del informe.

### Caminos independientes

| Camino | Secuencia logica | Datos de prueba | Resultado esperado |
|---|---|---|---|
| CB10-01 | C1 Si | correo en blanco, codigo `123456` | `ValidacionError`; no consultar repositorio |
| CB10-02 | C1 No -> C2 Si | correo valido, codigo vacio | `ValidacionError`; no consultar repositorio |
| CB10-03 | C1 No -> C2 No -> C3 No | codigo `12A456` | `ValidacionError` por formato |
| CB10-04 | C3 Si -> C4 No | correo inexistente | `UsuarioNoEncontradoError` |
| CB10-05 | C4 Si -> C5 Si | usuario `ACTIVO` | `CodigoVerificacionUsadoError` |
| CB10-06 | C5 No -> C6 Si | expiracion nula | `CodigoVerificacionVencidoError` |
| CB10-07 | C6 No -> C7 Si | expiracion igual al reloj | `CodigoVerificacionVencidoError` |
| CB10-08 | C7 No -> C8 No | codigo `654321`, digest distinto | `CodigoVerificacionInvalidoError` |
| CB10-09 | C7 No -> C8 Si | codigo `123456`, vigente | Usuario `ACTIVO`, codigo consumido |

### Resultado

| Caso | Resultado obtenido | Estado |
|---|---|---|
| CB10-01 a CB10-09 | Las excepciones, cortes tempranos y efectos esperados fueron comprobados con aserciones | Aprobado |

Cobertura estructural disenada: 9 de 9 caminos independientes ejecutados. No se declara porcentaje de lineas o ramas porque el repositorio no incluye una herramienta de instrumentacion como SimpleCov.

## 10.2.4 Prueba de caja blanca: orquestacion del lote offline

- **Responsable:** Jose Fabrizzio Bustillos Rivera
- **Modulo evaluado:** Modo offline y sincronizacion automatica
- **Clase evaluada:** `app/application/use_cases/asistencias/sincronizar_marcaciones_offline.rb`
- **Metodo evaluado:** `#ejecutar`

### Descripcion del metodo evaluado

Recorre el lote recibido, exige un identificador idempotente, detecta duplicados, sincroniza registros nuevos y aisla errores por elemento para conservar un resultado parcial.

### Condiciones evaluadas

| Condicion | Descripcion | Resultado posible |
|---|---|---|
| C1 | El bucle tiene una marcacion por procesar | Si / No |
| C2 | `cliente_marcacion_id` vacio | Si / No |
| C3 | Existe un registro con el mismo identificador | Si / No |
| C4 | La creacion produce un error de dominio controlado | Si / No |
| C5 | El procesamiento produce un error inesperado | Si / No |

### Complejidad ciclomatica

- Formula: `V(G) = numero de decisiones + 1`.
- Decisiones identificadas: 5.
- `V(G) = 5 + 1 = 6`.
- Cada brazo `rescue` representa una salida alternativa del flujo.

### Caminos independientes

| Camino | Secuencia logica | Datos de prueba | Resultado esperado |
|---|---|---|---|
| CB15A-01 | C1 No | lote vacio | Colecciones de resultado vacias |
| CB15A-02 | C1 Si -> C2 Si | elemento sin identificador | Elemento en `fallidos` |
| CB15A-03 | C2 No -> C3 Si | identificador existente | Elemento en `duplicados` |
| CB15A-04 | C3 No -> C4 No -> C5 No | registro nuevo valido | Elemento en `sincronizados` |
| CB15A-05 | C3 No -> C4 Si | `ValidacionError` controlado | Error aislado en `fallidos` |
| CB15A-06 | C3 No -> C4 No -> C5 Si | `StandardError` del repositorio | Error aislado en `fallidos` |

### Resultado

Cobertura estructural disenada: 6 de 6 caminos independientes ejecutados y aprobados.

## 10.2.5 Prueba de caja blanca: tipo y hora original

- **Responsable:** Jose Fabrizzio Bustillos Rivera
- **Modulo evaluado:** Modo offline y sincronizacion automatica
- **Clase evaluada:** `app/application/use_cases/asistencias/sincronizar_marcaciones_offline.rb`
- **Metodos evaluados:** `#crear_registro!` y `#parse_fecha!`, ejercidos desde `#ejecutar`

### Descripcion de los metodos evaluados

Convierten identificadores y coordenadas, validan la hora original ISO8601 y dirigen la marcacion hacia entrada o salida. Una fecha vacia, malformada o un tipo desconocido se devuelve como fallo del elemento.

### Condiciones evaluadas

| Condicion | Descripcion | Resultado posible |
|---|---|---|
| C1 | Fecha original vacia | Si / No |
| C2 | `Time.iso8601` produce `ArgumentError` | Si / No |
| C3 | Tipo igual a `ENTRADA` | Si / No |
| C4 | Tipo igual a `SALIDA` | Si / No |

### Complejidad ciclomatica

- Formula: `V(G) = numero de decisiones + 1`.
- Decisiones identificadas: 4.
- `V(G) = 4 + 1 = 5`.
- El `case` con tres salidas aporta dos decisiones independientes.

### Caminos independientes

| Camino | Secuencia logica | Datos de prueba | Resultado esperado |
|---|---|---|---|
| CB15B-01 | C1 No -> C2 No -> C3 Si | `ENTRADA`, fecha ISO8601 con `-05:00` | Sincroniza preservando el instante original |
| CB15B-02 | C1 No -> C2 No -> C3 No -> C4 Si | `SALIDA`, fecha ISO8601 con `-05:00` | Sincroniza preservando el instante original |
| CB15B-03 | C3 No -> C4 No | tipo `PAUSA` | Fallido por tipo no permitido |
| CB15B-04 | C1 Si | fecha en blanco | Fallido por fecha obligatoria |
| CB15B-05 | C1 No -> C2 Si | fecha `13/07/2026 08:15` | Fallido por formato ISO8601 |

### Resultado

Cobertura estructural disenada: 5 de 5 caminos independientes ejecutados y aprobados.

## Evidencia de ejecucion

Comando focalizado ejecutado en Ruby 4.0.4, Rails 8.1.3 y PostgreSQL 17, con `RAILS_ENV=test` y la base aislada `MarcaYa_test_whitebox`:

```powershell
bundle exec rails test `
  test-is2/smashalv/us_nueva_10/verificar_cuenta_caja_blanca_test.rb `
  test-is2/smashalv/us_nueva_15/sincronizar_marcaciones_offline_caja_blanca_test.rb
```

Salida obtenida:

```text
20 runs, 105 assertions, 0 failures, 0 errors, 0 skips
```

Analisis estatico focalizado:

```powershell
bundle exec rubocop `
  test-is2/smashalv/us_nueva_10/verificar_cuenta_caja_blanca_test.rb `
  test-is2/smashalv/us_nueva_15/sincronizar_marcaciones_offline_caja_blanca_test.rb
```

Salida obtenida:

```text
2 files inspected, no offenses detected
```

Resumen estructural total: 20 de 20 caminos disenados ejecutados, 105 aserciones y ningun fallo en las pruebas nuevas.

## Regresion y defectos observados

Tambien se ejecutaron completas las carpetas `us_nueva_10` y `us_nueva_15`. El resultado fue:

```text
61 runs, 269 assertions, 0 failures, 13 errors, 0 skips
```

Los 13 errores pertenecen a pruebas de controlador ya existentes y aparecen durante la carga global de fixtures, antes de ejecutar el cuerpo del caso. PostgreSQL informa que `registro_asistencias.empleado_id = 1` no existe en `empleados` al validar `fk_rails_a9dbc6bfe6`.

| Defecto | Impacto | Accion recomendada |
|---|---|---|
| Fixtures con referencia fija a `empleado_id: 1` | Impide ejecutar juntas ciertas pruebas de integracion | Referenciar la etiqueta del fixture de empleado o crear el empleado asociado en el setup |
| Sin herramienta de cobertura instrumentada | No hay porcentaje confiable de lineas o ramas | Agregar SimpleCov en una historia separada y fijar un umbral acordado |
| HU3 sin implementacion en `main` | No se puede construir grafo de control real | Integrar primero el caso de uso, endpoint y persistencia de justificaciones |

El defecto de fixtures tambien se reproduce sin depender de los fakes de caja blanca. No se corrigio en esta rama porque pertenece a la infraestructura compartida de pruebas y requiere coordinacion con el equipo.

## Archivos de prueba

- `test-is2/smashalv/us_nueva_10/verificar_cuenta_caja_blanca_test.rb`
- `test-is2/smashalv/us_nueva_15/sincronizar_marcaciones_offline_caja_blanca_test.rb`
- `test-is2/smashalv/RESULTADO_PRUEBAS_CAJA_BLANCA.txt`

## Conclusion

La entrega agrega evidencia formal de caja blanca para los dos modulos implementados y disponibles en `main`. Los 20 caminos independientes definidos por la complejidad ciclomatica fueron ejecutados satisfactoriamente. La incidencia de fixtures queda documentada sin atribuirla a los metodos evaluados ni alterar codigo de otros integrantes.
