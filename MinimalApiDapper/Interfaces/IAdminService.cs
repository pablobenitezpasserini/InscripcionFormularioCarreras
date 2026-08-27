using System.Threading.Tasks;

public interface IAdminService
{
    Task<Result<string>> LoguearAsync(string usuario, string contrasena);
    Task<Result<byte[]>> ExportarEstudiantesExcelAsync();
}