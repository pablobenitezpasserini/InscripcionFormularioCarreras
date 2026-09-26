using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace MinimalApiDapper.DTO.HabilitacionFormulario
{
    public class FormularioDisponibleDto
    {
        public int Año { get; set; }
        public DateTime FechaInicio { get; set; }
        public DateTime FechaCierre { get; set; }
    }
}