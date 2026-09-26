using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using MinimalApiDapper.Models;

namespace MinimalApiDapper.Interfaces
{
    public interface IAdminRepository
    {
        Task<IEnumerable<Administrador>> ListarAsync();

        Task CrearAsync(Administrador admin);

        Task EditarAsync(Administrador admin);

        Task EliminarAsync(int id);
    }
}