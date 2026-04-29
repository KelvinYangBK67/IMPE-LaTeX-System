"""Registry-driven dependency checking for IMPE Studio Lite."""

from .manager import DependencyManager
from .models import DependencyReport, DependencyResult, DependencySpec

__all__ = ["DependencyManager", "DependencyReport", "DependencyResult", "DependencySpec"]

