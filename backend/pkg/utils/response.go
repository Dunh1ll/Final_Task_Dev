package utils

import (
	"net/http"

	"github.com/gin-gonic/gin"
)

// Response is the standard envelope for all API responses.
// Every endpoint returns this structure so the Flutter app
// can consistently check for success/error.
type Response struct {
	Success bool        `json:"success"`           // true on success, false on error
	Message string      `json:"message,omitempty"` // human-readable message
	Data    interface{} `json:"data,omitempty"`    // payload on success
	Error   string      `json:"error,omitempty"`   // error message on failure
}

// SuccessResponse sends a 200 OK with data payload.
// Used when the response has data to return (e.g. profile list, auth token).
func SuccessResponse(c *gin.Context, data interface{}) {
	c.JSON(http.StatusOK, Response{
		Success: true,
		Data:    data,
	})
}

// SuccessMessage sends a 200 OK with a message and optional data.
// Used for operations like update/delete that return a confirmation message.
func SuccessMessage(c *gin.Context, message string, data interface{}) {
	c.JSON(http.StatusOK, Response{
		Success: true,
		Message: message,
		Data:    data,
	})
}

// ErrorResponse sends an error response with a custom HTTP status code.
// Used for specific errors like 403 Forbidden or 409 Conflict.
func ErrorResponse(c *gin.Context, statusCode int, message string) {
	c.JSON(statusCode, Response{
		Success: false,
		Error:   message,
	})
}

// ValidationError sends a 400 Bad Request for invalid request body/fields.
func ValidationError(c *gin.Context, message string) {
	ErrorResponse(c, http.StatusBadRequest, message)
}

// UnauthorizedError sends a 401 Unauthorized response.
// Used when the token is missing, invalid, or expired.
func UnauthorizedError(c *gin.Context) {
	ErrorResponse(c, http.StatusUnauthorized, "Unauthorized")
}

// NotFoundError sends a 404 Not Found response.
// The resource parameter names what was not found (e.g. "Profile").
func NotFoundError(c *gin.Context, resource string) {
	ErrorResponse(c, http.StatusNotFound, resource+" not found")
}

// InternalServerError sends a 500 Internal Server Error.
// Used when an unexpected database or server error occurs.
func InternalServerError(c *gin.Context) {
	ErrorResponse(c, http.StatusInternalServerError, "Internal server error")
}
