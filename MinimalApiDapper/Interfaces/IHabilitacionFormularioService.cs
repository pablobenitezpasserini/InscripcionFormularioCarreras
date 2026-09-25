using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using MinimalApiDapper.DTO.HabilitacionFormulario;
using MinimalApiDapper.Models;

namespace MinimalApiDapper.Interfaces
{
    public interface IHabilitacionFormularioService
    {
        Task<Result<bool>> CrearAsync(CrearHabilitacionFormularioDto data);

        Task<Result<bool>> EditarAsync(int id, EditarHabilitacionFormularioDto data);

        Task<Result<bool>> EliminarAsync(int id);

        Task<Result<bool>> EstaDisponibleAsync();
    }
}