using MinimalApiDapper.Models;
using System.Collections.Generic;
using System.Threading.Tasks;
using MinimalApiDapper.Data;
using System;
using System.IO;
using System.Linq;
using ClosedXML.Excel;


namespace MinimalApiDapper.Services;

public class AdminService : IAdminService
{
    private readonly AdminRepository _adminRepository;

    public AdminService(AdminRepository adminRepository)
    {
        _adminRepository = adminRepository;
    }

    public async Task<Result<string>> LoguearAsync(string usuario, string contrasena)
    {
        var mensaje = await _adminRepository.LoguearAsync(usuario, contrasena);

        if (mensaje.Contains("exitoso", StringComparison.OrdinalIgnoreCase)) //Si el mensaje recibido por la base de datos contiene la palabra "exitoso"
        {
            return Result<string>.Ok(mensaje);   
        }

        return Result<string>.Fail(mensaje);
    }

    public async Task<Result<byte[]>> ExportarEstudiantesExcelAsync()
    {
        var data = (await _adminRepository.ListarEstudiantesCarrerasInfoAcaAsync()).ToList();

        if (!data.Any()) //Si no hay datos en la consulta hecha anteriormente
        {
            return Result<byte[]>.Fail("No hay inscripciones hechas.");
        }

        using var workbook = new XLWorkbook(); //Se crea una nueva hoja de excel usando la libreria ClosedXML
        var worksheet = workbook.Worksheets.Add("Estudiantes"); //Se agrega una nueva hoja a ese excel con el nombre "Estudiantes"

        var table = worksheet.Cell(1, 1).InsertTable(data); //Se inserta la data obtenida anteriormente en la hoja de excel, a partir de la celda A1 (fila 1, columna 1)
        worksheet.Columns().AdjustToContents(); //Se ajusta las columnas para adaptarse al contenido de las celdas

        using var stream = new MemoryStream(); //Se crea un stream de memoria para guardar el archivo de excel generado en la memoria, sin necesidad de guardarlo en el disco duro del servidor
        workbook.SaveAs(stream); //Se guarda el archivo de excel en el stream de memoria

        return Result<byte[]>.Ok(stream.ToArray());
    }

}
