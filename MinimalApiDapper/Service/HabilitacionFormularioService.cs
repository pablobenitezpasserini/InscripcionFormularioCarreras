using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.Data.SqlClient;
using MinimalApiDapper.Data;
using MinimalApiDapper.DTO.HabilitacionFormulario;
using MinimalApiDapper.Interfaces;
using MinimalApiDapper.Models;

namespace MinimalApiDapper.Service
{
    public class HabilitacionFormularioService : IHabilitacionFormularioService
    {
        private readonly HabilitacionFormularioRepository _repository;
        public HabilitacionFormularioService(HabilitacionFormularioRepository repository)
        {
            _repository = repository;
        }

        public async Task<Result<bool>> CrearAsync(CrearHabilitacionFormularioDto data)
        {
            try
            {
                var formulario = new HabilitacionFormulario
                {
                    Hab_Form_Año = data.Hab_Form_Año,
                    Hab_Form_Fecha_Inicio = data.Hab_Form_Fecha_Inicio,
                    Hab_Form_Fecha_Cierre = data.Hab_Form_Fecha_Cierre,

                    // Regla de negocio:
                    Hab_Form_Estado = "DESHABILITADO"
                };
                await _repository.CrearAsync(formulario);

                return Result<bool>.Ok(true);
            }
            catch (SqlException ex)
            {
                return Result<bool>.Fail(ex.Message);
            }
        }

        public async Task<Result<bool>> EditarAsync(int id, EditarHabilitacionFormularioDto data)
        {
            try
            {
                var formulario = new HabilitacionFormulario
                {
                  ID_Hab_Form = id,
                  Hab_Form_Fecha_Inicio = data.Hab_Form_Fecha_Inicio,
                  Hab_Form_Fecha_Cierre = data.Hab_Form_Fecha_Cierre,
                  Hab_Form_Estado = data.Hab_Form_Estado  
                };

                await _repository.EditarAsync(formulario);

                return Result<bool>.Ok(true);
            }
            catch (SqlException ex)
            {
                return Result<bool>.Fail(ex.Message);
            }
        }

        public async Task<Result<bool>> EliminarAsync(int id)
        {
            try
            {
                await _repository.EliminarAsync(id);

                return Result<bool>.Ok(true);
            }
            catch (SqlException ex)
            {
                return Result<bool>.Fail(ex.Message);
            }
        }

        public Task<Result<bool>> EstaDisponibleAsync()
        {
            throw new NotImplementedException();
        }
    }
}