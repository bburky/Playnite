using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Playnite.SDK
{
    /// <summary>
    /// Describes settings object.
    /// </summary>
    public interface ISettings : IEditableObject
    {
        /// <summary>
        /// Verifies settings configuration.
        /// </summary>
        /// <param name="errors">List of validation errors.</param>
        /// <returns>true if validation passes, otherwise false.</returns>
        bool VerifySettings(out List<string> errors);
    }

    /// <summary>
    /// Abstract ISettings for use with PowerShell classes
    /// </summary>
    public abstract class PowerShellSettings : ISettings
    {
        public abstract void BeginEdit();
        public abstract void CancelEdit();
        public abstract void EndEdit();
        public abstract List<string> VerifySettings();

        /// <summary>
        /// Verifies settings configuration.
        /// </summary>
        /// <param name="errors">List of validation errors.</param>
        /// <returns>true if validation passes, otherwise false.</returns>
        bool ISettings.VerifySettings(out List<string> errors)
        {
            errors = VerifySettings();
            if (errors != null && errors.Any())
            {
                return false;
            }
            return true;
        }
    }
}