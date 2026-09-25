using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Threading.Tasks;
using Dapper;
using Microsoft.Data.SqlClient;
using MinimalApiDapper.Interfaces;
using MinimalApiDapper.Models;

namespace MinimalApiDapper.Data
{
    public class HabilitacionFormularioRepository : IHabilitacionFormularioRepository
    {
        private readonly string _connectionString;

        public HabilitacionFormularioRepository(string connectionString)
        {
            _connectionString = connectionString;
        }

        public async Task CrearAsync(HabilitacionFormulario formulario)
        {
            using var connection = new SqlConnection(_connectionString);
            var parameters = new DynamicParameters();

            parameters.Add("@Hab_Form_Año", formulario.Hab_Form_Año);
            parameters.Add("@Hab_Form_Fecha_Inicio", formulario.Hab_Form_Fecha_Inicio);
            parameters.Add("@Hab_Form_Fecha_Cierre", formulario.Hab_Form_Fecha_Cierre);

            await connection.ExecuteAsync("sp_Insert_Habilitacion_Formulario", parameters, commandType: CommandType.StoredProcedure);
        }

        public async Task EditarAsync(HabilitacionFormulario formulario)
        {
            using var connection = new SqlConnection(_connectionString);
            var parameters = new DynamicParameters();

            parameters.Add("@ID_Hab_Form", formulario.ID_Hab_Form);
            parameters.Add("@Hab_Form_Fecha_Inicio", formulario.Hab_Form_Fecha_Inicio);
            parameters.Add("@Hab_Form_Fecha_Cierre", formulario.Hab_Form_Fecha_Cierre);
            parameters.Add("@Hab_Form_Estado", formulario.Hab_Form_Estado);

            await connection.ExecuteAsync("sp_Update_Habilitacion_Formulario", parameters, commandType: CommandType.StoredProcedure);
        }

        public async Task EliminarAsync(int id)
        {
            using var connection = new SqlConnection(_connectionString);
            var parameters = new DynamicParameters();

            parameters.Add("@ID_Hab_Form", id);

            await connection.ExecuteAsync("sp_Delete_Habilitacion_Formulario", parameters, commandType: CommandType.StoredProcedure);
        }

        public Task<IEnumerable<HabilitacionFormulario>> ListarAsync()
        {
            throw new NotImplementedException();
        }
    }
}