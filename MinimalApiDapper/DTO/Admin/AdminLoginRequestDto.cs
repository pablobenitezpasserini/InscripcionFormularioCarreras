using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace MinimalApiDapper.DTO.Admin
{
    public class AdminLoginRequestDto
    {
        public string Usuario {get; set;}
        public string Contrasena {get; set;}
    }
}