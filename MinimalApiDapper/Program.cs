using Microsoft.AspNetCore.Builder;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Hosting;
using MinimalApiDapper.Data;
using MinimalApiDapper.Services;
using MinimalApiDapper.Models;
using Microsoft.AspNetCore.Http;
using System;

namespace MinimalApiDapper;

public class Program
{
    public static void Main(string[] args)
    {
        var builder = WebApplication.CreateBuilder(args);

        // Add services to the container.
        builder.Services.AddAuthorization();

        // Habilitar CORS
        builder.Services.AddCors();

    // Learn more about configuring Swagger/OpenAPI at
    //https://aka.ms/aspnetcore/swashbuckle
        builder.Services.AddEndpointsApiExplorer();
        builder.Services.AddSwaggerGen();

        string connectionString = "Server=localhost\\SQLEXPRESS;Database=FormularioInscripcionCarreras;Trusted_Connection=True;TrustServerCertificate=True;";
        //string de conexion a la base de datos. Recuerden cambiar el nombre del servidor y la base de datos para que el proyecto funcione

        // Add database connection string to the services
        builder.Services.AddSingleton<AdminRepository>(_ => new
        AdminRepository(connectionString));
        builder.Services.AddSingleton<IAdminService, AdminService>();

        var app = builder.Build();

        // Configure the HTTP request pipeline.
        if (app.Environment.IsDevelopment())
        {
            app.UseSwagger();
            app.UseSwaggerUI();
        }
        //No se olviden hacer en cualquier navegador localhost:<puerto>/swagger para probar los endpoints sin necesidad de usar la pagina web
        app.UseHttpsRedirection();

        app.UseAuthorization();

        // Permitir CORS para todo el mundo
        app.UseCors(builder => builder
        .AllowAnyOrigin()
        .AllowAnyMethod()
        .AllowAnyHeader()
        );

        // Get services
        var alumnoService = app.Services.GetRequiredService<IAdminService>();

        app.MapPost("/api/admin/login", async (LoginRequest data, IAdminService service) =>
        {
            var result = await service.LoguearAsync(data.usuario, data.contrasena);

            if (result.Success)
            {
                return Results.Ok(new { mensaje = result.Data });
            }

            return Results.BadRequest(new { mensaje = result.Error });
        });

        app.MapGet("/api/admin/exportar-estudiantes", async (IAdminService service) =>
        {
            var result = await service.ExportarEstudiantesExcelAsync();

            if (result.Success) //Esto le devuelve al frontend el archivo de excel, el tipo indicado de documento y el nombre por defecto del archivo
            {
                return Results.File(result.Data!,"application/vnd.openxmlformats-officedocument.spreadsheetml.sheet","Estudiantes.xlsx");
            }

            return Results.BadRequest(new { message = result.Error });
        });

        app.Run();
    }
}

public record LoginRequest(string usuario, string contrasena); //Necesario para recibir los datos del login en el endpoint de login