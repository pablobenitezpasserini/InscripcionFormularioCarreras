using Dapper;
using Microsoft.Data.SqlClient;
using MinimalApiDapper.Models;
using System.Data;
using System.Threading.Tasks;
using System.Collections.Generic;
using MinimalApiDapper.DTO;
using MinimalApiDapper.Interfaces;

namespace MinimalApiDapper.Data;

public class AdminRepository : IAdminRepository
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

    public async Task<IEnumerable<EstudianteExportacionDto>> ListarEstudiantesCarrerasInfoAcaAsync()
    {
        using var connection = new SqlConnection(_connectionString);
        
        return await connection.QueryAsync<EstudianteExportacionDto>("SP_exportacionDelExcel",commandType: CommandType.StoredProcedure);
    }

    public async Task<IEnumerable<Administrador>> ListarAsync()
    {
        using var connection = new SqlConnection(_connectionString);

        return await connection.QueryAsync<Administrador>("sp_Listar_Admin", commandType: CommandType.StoredProcedure);
    }

    public Task CrearAsync(Administrador admin)
    {
        throw new System.NotImplementedException();
    }

    public Task EditarAsync(Administrador admin)
    {
        throw new System.NotImplementedException();
    }

    public Task EliminarAsync(int id)
    {
        throw new System.NotImplementedException();
    }
}
