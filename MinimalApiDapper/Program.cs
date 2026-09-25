using Microsoft.AspNetCore.Builder;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Hosting;
using MinimalApiDapper.Data;
using MinimalApiDapper.Services;
using MinimalApiDapper.Models;
using Microsoft.AspNetCore.Http;
using System;
using Microsoft.Extensions.Configuration;
using MinimalApiDapper.DTO.Admin;
using MinimalApiDapper.Service;
using MinimalApiDapper.Interfaces;
using MinimalApiDapper.DTO.HabilitacionFormulario;

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

        string connectionString = builder.Configuration.GetConnectionString("DefaultConnection");
        //string de conexion a la base de datos. Recuerden cambiar el nombre del servidor y la base de datos para que el proyecto funcione

        // Add database connection string to the services
        builder.Services.AddSingleton<AdminRepository>(_ => new
        AdminRepository(connectionString));
        builder.Services.AddSingleton<IAdminService, AdminService>();
        
        builder.Services.AddSingleton<HabilitacionFormularioRepository>(_ => new
        HabilitacionFormularioRepository(connectionString));
        builder.Services.AddSingleton<IHabilitacionFormularioService, HabilitacionFormularioService>();

        var app = builder.Build();

        // Configure the HTTP request pipeline.
        if (app.Environment.IsDevelopment())
        {
            app.UseSwagger();
            app.UseSwaggerUI();
        }

        app.UseDefaultFiles();
        app.UseStaticFiles();
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

        app.MapPost("/api/admin/login", async (AdminLoginRequestDto data, IAdminService service) =>
        {
            var result = await service.LoguearAsync(data.Usuario, data.Contrasena);

            if (result.Success)
            {
                return Results.Ok(new { mensaje = result.Data });
            }

            return Results.BadRequest(new { mensaje = result.Error });
        });

        app.MapGet("/api/admin/exportar-estudiantes", async (IAdminService service) =>
        {
            var result = await service.ExportarEstudiantesExcelAsync();

            if (result.Success)
            {
                return Results.Ok(result.Data);
            }

            return Results.BadRequest(new { message = result.Error });
        });

        //endpoints habilitacionFormulario
        app.MapPost("/api/admin/formularios", async (CrearHabilitacionFormularioDto data, IHabilitacionFormularioService service) =>
        {
            var result = await service.CrearAsync(data);

            if (!result.Success)
            {
                return Results.BadRequest(new
                {
                    mensaje = result.Error
                });
            }

            return Results.Ok(new
            {
                mensaje = "Formulario creado correctamente."
            });
        }
        );

        app.MapPut("/api/admin/formularios/{id}", async (int id, EditarHabilitacionFormularioDto data, IHabilitacionFormularioService service) =>
        {
            var result = await service.EditarAsync(id, data);

            if (!result.Success)
            {
                return Results.BadRequest(new
                {
                    mensaje = result.Error
                });
            }

            return Results.Ok(new
            {
                mensaje = "Formulario actualizado correctamente."   
            });
        }
        );

        app.MapDelete("/api/admin/formularios/{id}", async (int id, IHabilitacionFormularioService service) =>
        {
            var result = await service.EliminarAsync(id);

            if(!result.Success)
            {
                return Results.BadRequest(new
                {
                    mensaje = result.Error
                });
            }

            return Results.Ok(new
            {
                mensaje = "Formulario eliminado correctamente."
            });
        }
        );
        
        app.Run();
    }
}