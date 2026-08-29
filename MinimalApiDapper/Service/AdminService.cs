using MinimalApiDapper.Models;
using System.Collections.Generic;
using System.Threading.Tasks;
using MinimalApiDapper.Data;
using System;
using System.IO;
using System.Linq;
using ClosedXML.Excel;
using MinimalApiDapper.DTO;


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

    public async Task<Result<IEnumerable<EstudianteExportacionDto>>> ExportarEstudiantesExcelAsync()
    {
        var data = (await _adminRepository.ListarEstudiantesCarrerasInfoAcaAsync()).ToList();

        if (!data.Any())
        {
            return Result<IEnumerable<EstudianteExportacionDto>>.Fail(
                "No hay inscripciones hechas."
            );
        }

        return Result<IEnumerable<EstudianteExportacionDto>>.Ok(data);
    }

}
