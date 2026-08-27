public class Result<T>
{
    public bool Success { get; }
    public T? Data { get; }
    public string? Error { get; }

    private Result(bool success, T? data, string? error)
    {
        Success = success;
        Data = data;
        Error = error;
    }

    public static Result<T> Ok(T data)
        => new Result<T>(true, data, null); //Devuelve Success=true, el dato recibido por parametro y error=null

    public static Result<T> Fail(string error)
        => new Result<T>(false, default, error); //Devuelve Success=false, el dato con su valor por defecto (null para tipos de referencia) y el mensaje de error recibido por parametro
}