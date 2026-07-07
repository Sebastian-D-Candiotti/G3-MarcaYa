# frozen_string_literal: true

module Infrastructure
  module Services
    class AsistenciaPdfService
      PAGE_WIDTH = 595
      PAGE_HEIGHT = 842
      MARGIN = 42
      LINE_HEIGHT = 16
      MAX_LINES_PER_PAGE = 45

      def call(informe)
        snapshot = informe.snapshot
        lines = build_lines(informe, snapshot)
        pages = lines.each_slice(MAX_LINES_PER_PAGE).to_a
        build_pdf(pages)
      end

      private

      def build_lines(informe, snapshot)
        empresa = snapshot.fetch("empresa", {})
        periodo = snapshot.fetch("periodo", {})
        resumen = snapshot.fetch("resumen", {})
        empleados = snapshot.fetch("empleados", [])
        limitaciones = snapshot.fetch("limitaciones", {})

        lines = [
          ["MarcaYA - Informe de asistencia", 16],
          ["Empresa: #{empresa['nombre']} | RUC: #{empresa['ruc']}", 11],
          ["Tipo: #{periodo['tipo']} | Periodo: #{periodo['fecha_inicio']} al #{periodo['fecha_fin']}", 11],
          ["Estado: #{informe.estado} | Generado: #{informe.fecha_generacion}", 11],
          ["Checksum: #{informe.checksum}", 8],
          ["", 10],
          ["Resumen general", 13],
          ["Empleados incluidos: #{resumen['empleados_incluidos']}", 10],
          ["Total marcaciones: #{resumen['total_marcaciones']} | Entradas: #{resumen['entradas']} | Salidas: #{resumen['salidas']}", 10],
          ["Horas trabajadas: #{resumen['horas_trabajadas']} | GPS valido: #{resumen['porcentaje_gps_valido']}%", 10],
          ["Tardanzas: #{resumen['tardanzas']} | Inasistencias: #{resumen['inasistencias']} | Justificaciones: #{resumen['justificaciones']}", 10],
          ["Marcaciones invalidas: #{resumen['marcaciones_invalidas']} | Fake GPS: #{resumen['fake_gps']}", 10],
          ["", 10],
          ["Detalle por empleado", 13],
          ["Empleado | DNI | Marc. | Horas | Tard. | Inasist. | Invalidas | FakeGPS", 9]
        ]

        if empleados.empty?
          lines << ["Sin registros para el periodo.", 10]
        else
          empleados.each do |empleado|
            lines << [
              [
                empleado["nombre"],
                empleado["dni"],
                empleado["total_marcaciones"],
                empleado["horas_trabajadas"],
                empleado["tardanzas"],
                empleado["inasistencias"],
                empleado["marcaciones_invalidas"],
                empleado["fake_gps"]
              ].join(" | "),
              8
            ]
          end
        end

        lines += [
          ["", 10],
          ["Notas y limitaciones", 13]
        ]
        limitaciones.each_value { |value| lines << [value.to_s, 9] }
        lines
      end

      def build_pdf(pages)
        objects = []
        font_obj = 3
        page_objects = []
        content_objects = []

        pages.each_with_index do |page_lines, index|
          page_obj = 4 + index * 2
          content_obj = page_obj + 1
          page_objects << page_obj
          content_objects << content_obj

          objects[page_obj] = "<< /Type /Page /Parent 2 0 R /MediaBox [0 0 #{PAGE_WIDTH} #{PAGE_HEIGHT}] /Resources << /Font << /F1 #{font_obj} 0 R >> >> /Contents #{content_obj} 0 R >>"
          stream = content_stream(page_lines, index + 1, pages.length)
          objects[content_obj] = "<< /Length #{stream.bytesize} >>\nstream\n#{stream}\nendstream"
        end

        objects[1] = "<< /Type /Catalog /Pages 2 0 R >>"
        objects[2] = "<< /Type /Pages /Kids [#{page_objects.map { |id| "#{id} 0 R" }.join(' ')}] /Count #{page_objects.length} >>"
        objects[font_obj] = "<< /Type /Font /Subtype /Type1 /BaseFont /Helvetica >>"

        serialize_pdf(objects)
      end

      def content_stream(lines, page_number, total_pages)
        y = PAGE_HEIGHT - MARGIN
        chunks = []
        lines.each do |text, size|
          size ||= 10
          if text.blank?
            y -= LINE_HEIGHT
            next
          end

          wrapped(text.to_s, size).each do |line|
            chunks << "BT /F1 #{size} Tf #{MARGIN} #{y} Td #{pdf_text(line)} Tj ET"
            y -= LINE_HEIGHT
          end
        end
        chunks << "BT /F1 8 Tf #{MARGIN} 24 Td #{pdf_text("Pagina #{page_number} de #{total_pages}")} Tj ET"
        chunks.join("\n")
      end

      def wrapped(text, size)
        max_chars = size <= 8 ? 110 : 95
        words = text.split(/\s+/)
        lines = []
        current = +""

        words.each do |word|
          candidate = current.empty? ? word : "#{current} #{word}"
          if candidate.length > max_chars
            lines << current
            current = word
          else
            current = candidate
          end
        end
        lines << current unless current.empty?
        lines
      end

      def pdf_text(text)
        encoded = "\uFEFF#{text}".encode("UTF-16BE", invalid: :replace, undef: :replace, replace: "?")
        "<#{encoded.unpack1('H*')}>"
      end

      def serialize_pdf(objects)
        pdf = +"%PDF-1.4\n"
        offsets = [0]

        objects.each_with_index do |object, index|
          next if index.zero? || object.nil?

          offsets[index] = pdf.bytesize
          pdf << "#{index} 0 obj\n#{object}\nendobj\n"
        end

        xref_offset = pdf.bytesize
        max_object = objects.length - 1
        pdf << "xref\n0 #{max_object + 1}\n"
        pdf << "0000000000 65535 f \n"
        (1..max_object).each do |index|
          pdf << format("%010d 00000 n \n", offsets[index] || 0)
        end
        pdf << "trailer\n<< /Size #{max_object + 1} /Root 1 0 R >>\n"
        pdf << "startxref\n#{xref_offset}\n%%EOF\n"
        pdf
      end
    end
  end
end
