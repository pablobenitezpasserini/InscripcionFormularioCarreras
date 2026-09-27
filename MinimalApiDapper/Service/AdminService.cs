using MinimalApiDapper.Models;
using System.Collections.Generic;
using System.Threading.Tasks;
using MinimalApiDapper.Data;
using System;
using System.IO;
using System.Linq;
using MinimalApiDapper.DTO;
using Microsoft.Data.SqlClient;
using MinimalApiDapper.DTO.Admin;


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

    public async Task<Result<bool>> CrearAsync(CrearAdminDto admin)
    {
        try
        {    
            var nuevoAdmin = new Administrador()
            {
                Admin_Nom_Ape = admin.Admin_Nom_Ape,
                Admin_DNI = admin.Admin_DNI,
                Admin_Tipo_DNI = admin.Admin_Tipo_DNI,
                Admin_Nom_Usuario = admin.Admin_Nom_Usuario,
                Admin_Contra = admin.Admin_Contra
            };

            await _adminRepository.CrearAsync(nuevoAdmin);

            return Result<bool>.Ok(true);
        }
        catch(SqlException ex)
        {
            return Result<bool>.Fail(ex.Message); 
        }
    }

    public async Task<Result<bool>> EditarAsync(int id, EditarAdminDto admin)
    {
        try
        {
            var nuevoAdmin = new Administrador()
            {
                ID_Admin = id,
                Admin_Nom_Ape = admin.Admin_Nom_Ape,
                Admin_DNI = admin.Admin_DNI,
                Admin_Tipo_DNI = admin.Admin_Tipo_DNI,
                Admin_Nom_Usuario = admin.Admin_Nom_Usuario,
                Admin_Contra = admin.Admin_Contra
            };

            await _adminRepository.EditarAsync(nuevoAdmin);

            return Result<bool>.Ok(true);
        }
        catch(SqlException ex)
        {
            return Result<bool>.Fail(ex.Message);
        }
    }

    public async Task<Result<bool>> EliminarAsync(int id)
    {
        try
        {
            await _adminRepository.EliminarAsync(id);

            return Result<bool>.Ok(true);
        }
        catch(SqlException ex)
        {
            return Result<bool>.Fail(ex.Message);
        }
    }
}
