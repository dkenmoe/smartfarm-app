from django.db import models

class Sensor(models.Model):
    """IoT sensor installed in the farm"""
    name = models.CharField(max_length=100)
    type = models.CharField(max_length=50, choices=[('temperature', 'Temperature'), ('humidity', 'Humidity'), ('weight', 'Weight')])
    location = models.CharField(max_length=100)

    def __str__(self):
        return f"{self.name} ({self.type})"

class SensorReading(models.Model):
    """Stores real-time data from IoT sensors"""
    sensor = models.ForeignKey(Sensor, on_delete=models.CASCADE, related_name="readings")
    value = models.FloatField()
    recorded_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return f"{self.sensor.name} - {self.value} ({self.recorded_at})"
