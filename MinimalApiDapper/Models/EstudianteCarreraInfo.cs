using System;

public class EstudianteCarreraInfoDto
{
    public int ID_Est { get; set; }
    public string Nombre_Apellido { get; set; }
    public string DNI { get; set; }
    public string Correo { get; set; }
    public string Carrera { get; set; }
    public string Turno { get; set; }
    public string Info_Academica { get; set; }
    public DateTime? Fecha_Info { get; set; }
    public string Estado_Info { get; set; }
}