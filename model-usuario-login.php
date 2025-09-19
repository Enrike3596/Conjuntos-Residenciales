<?php
require_once __DIR__ . 'database.php';

class LoginUser {

    public function Inicio_Login($Correo_Electronico) {
        try {
            $conexion = new Database();
            $conecDB = $conexion->getConnection();

            $sql = "SELECT user_id, names, surnames, email, Clave_hash, role_user 
                    FROM users 
                    WHERE email = :email";
            $login_user = $conecDB->prepare($sql);

            $login_user->execute([":email" => $Correo_Electronico]);

            return $login_user->fetch(PDO::FETCH_ASSOC);

        } catch (PDOException $e) {
            throw new Exception("Error al consultar el usuario: " . $e->getMessage());
        }
    }
}
?>