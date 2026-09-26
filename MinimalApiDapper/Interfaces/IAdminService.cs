using System.Collections.Generic;
using System.Threading.Tasks;
using MinimalApiDapper.DTO;
using MinimalApiDapper.Models;

public interface IAdminService
{
    Task<Result<string>> LoguearAsync(string usuario, string contrasena);
    Task<Result<IEnumerable<Administrador>>> ListarAsync();
    Task<Result<bool>> CrearAsync(Administrador admin);
    Task<Result<bool>> EditarAsync(Administrador admin);
    Task<Result<bool>> EliminarAsync(int id);
    Task<Result<IEnumerable<EstudianteExportacionDto>>> ExportarEstudiantesExcelAsync();
}