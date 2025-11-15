# 🌐 Documentación de API

## Endpoints REST

### Autenticación
- `POST /api/auth/login` - Iniciar sesión
- `POST /api/auth/logout` - Cerrar sesión
- `POST /api/auth/refresh` - Refrescar token

### Robots
- `GET /api/robots/status` - Estado del robot
- `POST /api/robots/start` - Encender robot
- `POST /api/robots/stop` - Apagar robot
- `GET /api/robots/stats` - Estadísticas

### Módulos
- `GET /api/modules` - Listar módulos
- `POST /api/modules/activate` - Activar módulo
- `POST /api/modules/deactivate` - Desactivar módulo

### Ranking
- `GET /api/ranking/global` - Ranking global
- `GET /api/ranking/user` - Posición del usuario

---

## WebSocket

### Eventos
- `robot.status` - Cambio de estado del robot
- `stats.update` - Actualización de estadísticas
- `notification` - Notificaciones del sistema

---

**En desarrollo...**

