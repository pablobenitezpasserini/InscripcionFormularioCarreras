using System.Collections.Generic;
using System.Threading.Tasks;
using MinimalApiDapper.DTO;

public interface IAdminService
{
    Task<Result<string>> LoguearAsync(string usuario, string contrasena);
    Task<Result<IEnumerable<EstudianteExportacionDto>>> ExportarEstudiantesExcelAsync();
}