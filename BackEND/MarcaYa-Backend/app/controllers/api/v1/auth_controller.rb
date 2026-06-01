class Api::V1::AuthController < ApplicationController

  def login
    correo = params[:correo]
    clave  = params[:clave]

    usuario = Usuario.find_by(
      correo: correo,
      estado: true
    )

    if usuario.nil?
      render json: {
        error: "Usuario no encontrado"
      }, status: :unauthorized
      return
    end

    if usuario.clave_hash != clave
      render json: {
        error: "Contraseña incorrecta"
      }, status: :unauthorized
      return
    end

    if usuario.rol == "empresa"
      empresa = Empresa.find_by(
        usuario_id: usuario.id
      )

      valoraciones = Valoracion.where(
        empresa_id: empresa.id
      )

      promedio_estrellas =
        valoraciones.average(:puntuacion)&.round(1) || 0

      comentarios =
        valoraciones.map do |v|
          {
            comentario: v.comentario
          }
        end

      perfil = {
        id: usuario.id,
        correo: usuario.correo,
        rol: usuario.rol,
        nombre: empresa&.nombre_empresa,
        nombre_empresa: empresa&.nombre_empresa,
        descripcion: empresa&.descripcion,
        telefono: empresa&.telefono,
        direccion: empresa&.direccion,
        ruc: empresa&.ruc,
        foto_url: empresa&.foto_url
      }

    else

      empleado = Empleado.find_by(
        usuario_id: usuario.id
      )

      perfil = {
        id: usuario.id,
        employee_id: empleado.id,
        correo: usuario.correo,
        rol: usuario.rol,
        nombre: empleado&.nombre,
        apellido: empleado&.apellido,
        descripcion: empleado&.descripcion,
        telefono: empleado&.telefono,
        foto_url: empleado&.foto_url
      }

    end

    render json: {
      token: "token_demo",
      rol: usuario.rol,
      perfil: perfil
    }
  end

  def registro

    usuario = Usuario.create!(
      correo: params[:correo],
      clave_hash: params[:clave],
      rol: params[:rol]
    )

    render json: {
      mensaje: "Usuario registrado",
      id: usuario.id
    }, status: :created

  end

end