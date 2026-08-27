using Dapper;
using Microsoft.Data.SqlClient;
using MinimalApiDapper.Models;
using System.Data;
using System.Threading.Tasks;
using System.Collections.Generic;

namespace MinimalApiDapper.Data;

public class AdminRepository
{
    private readonly string _connectionString;

    public AdminRepository(string connectionString)
    {
        _connectionString = connectionString;
    }

    public async Task<string> LoguearAsync(string usuario, string contrasena)
    {
        using var connection = new SqlConnection(_connectionString);
        var parameters = new DynamicParameters();

        parameters.Add("@Admin_Nom_Usuario", usuario);
        parameters.Add("@Admin_Contra", contrasena);
        parameters.Add("@Mensaje", dbType: DbType.String, size: 100, direction: ParameterDirection.Output);

        await connection.ExecuteAsync("Logueo_Admin", parameters, commandType: CommandType.StoredProcedure);

        return parameters.Get<string>("@Mensaje");
    }

    public async Task<IEnumerable<EstudianteCarreraInfoDto>> ListarEstudiantesCarrerasInfoAcaAsync()
    {
        using var connection = new SqlConnection(_connectionString);
        return await connection.QueryAsync<EstudianteCarreraInfoDto>("sp_Listar_Estudiantes_Carreras_InfAca",commandType: CommandType.StoredProcedure);
    }
}
