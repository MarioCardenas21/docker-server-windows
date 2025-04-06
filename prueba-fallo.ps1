# Variables de conexión
$usuario = "sa"
$contrasena = "Mewvmax.1"
$baseDatos = "PruebaAG"

# 1. Primeros inserts desde sqlnode1
Write-Host "🟢 Iniciando transacción en sqlnode1..."
docker exec -i sqlnode1 sqlcmd -U $usuario -P $contrasena -d $baseDatos -Q @"
BEGIN TRAN;
INSERT INTO clientes (nombre, correo) VALUES ('Ana Pérez', 'ana@example.com');
INSERT INTO clientes (nombre, correo) VALUES ('Luis Gómez', 'luis@example.com');
"@

# 2. Apagar el nodo 1
Write-Host "⛔️ Apagando sqlnode1 (fallo simulado)..."
docker-compose stop sqlnode1
Start-Sleep -Seconds 5

# 3. Continuar la transacción desde sqlnode2
Write-Host "➡️ Continuando desde sqlnode2 (fallover automático esperado)..."
docker exec -i sqlnode2 sqlcmd -U $usuario -P $contrasena -d $baseDatos -Q @"
INSERT INTO clientes (nombre, correo) VALUES ('Carla Ruiz', 'carla@example.com');
INSERT INTO clientes (nombre, correo) VALUES ('Pedro López', 'pedro@example.com');
COMMIT;
"@

# 4. Validar datos
Write-Host "`n📋 Mostrando datos después de la prueba:"
docker exec -i sqlnode2 sqlcmd -U $usuario -P $contrasena -d $baseDatos -Q "SELECT * FROM clientes;"
