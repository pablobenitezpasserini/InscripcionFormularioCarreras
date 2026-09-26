using MinimalApiDapper.Models;
using System.Collections.Generic;
using System.Threading.Tasks;
using MinimalApiDapper.Data;
using System;
using System.IO;
using System.Linq;
using MinimalApiDapper.DTO;
using Microsoft.Data.SqlClient;


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

    public async Task<Result<IEnumerable<Administrador>>> ListarAsync()
    {
        try
        {
            var administradores = await _adminRepository.ListarAsync();

            return Result<IEnumerable<Administrador>>.Ok(administradores);
        }
        catch(SqlException ex)
        {
            return Result<IEnumerable<Administrador>>.Fail(ex.Message);
        }
    }

    public Task<Result<bool>> CrearAsync(Administrador admin)
    {
        throw new NotImplementedException();
    }

    public Task<Result<bool>> EditarAsync(Administrador admin)
    {
        throw new NotImplementedException();
    }

    public Task<Result<bool>> EliminarAsync(int id)
    {
        throw new NotImplementedException();
    }
}
