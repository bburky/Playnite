﻿using CefSharp;
using Playnite.Windows;
using Playnite.SDK;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading;
using System.Threading.Tasks;
using System.Windows.Media;

namespace Playnite.WebView
{
    public class WebView : IWebView
    {
        private readonly SynchronizationContext context;

        private AutoResetEvent loadCompleteEvent = new AutoResetEvent(false);

        private WebViewWindow window;

        public event EventHandler NavigationChanged;

        public WebView(int width, int height) : this(width, height, Colors.Transparent)
        {
        }

        public WebView(int width, int height, Color background)
        {
            context = SynchronizationContext.Current;
            window = new WebViewWindow();
            window.Browser.LoadingStateChanged += Browser_LoadingStateChanged;
            window.Owner = WindowManager.CurrentWindow;
            window.Width = width;
            window.Height = height;
            window.Background = new SolidColorBrush(background);
        }

        private void Browser_LoadingStateChanged(object sender, LoadingStateChangedEventArgs e)
        {
            if (e.IsLoading == false)
            {
                loadCompleteEvent.Set();
            }

            NavigationChanged?.Invoke(this, new EventArgs());
        }

        public void Close()
        {
            context.Send(a => window.Close(), null);
        }

        public void Dispose()
        {            
            window?.Close();
            window?.Browser.Dispose();
        }

        public string GetCurrentAddress()
        {
            var address = string.Empty;
            context.Send(a => address = window.Browser.Address, null);
            return address;
        }

        public string GetPageText()
        {
            var text = string.Empty;
            context.Send(a => text = window.Browser.GetTextAsync().GetAwaiter().GetResult(), null);
            return text;
        }

        public string GetPageSource()
        {
            var text = string.Empty;
            context.Send(a => text = window.Browser.GetSourceAsync().GetAwaiter().GetResult(), null);
            return text;
        }

        public Task<string> GetPageSourceAsync()
        {
            return window.Browser.GetSourceAsync();
        }

        public object EvaluateScript(string methodName, params object[] args)
        {
            JavascriptResponse response = null;
            context.Send(a => response = window.Browser.EvaluateScriptAsync(methodName, args).GetAwaiter().GetResult(), null);
            return response.Success ? (response.Result ?? "null") : response.Message;
        }

        public void NavigateAndWait(string url)
        {
            context.Send(a => window.Browser.Address = url, null);            
            loadCompleteEvent.WaitOne(20000);
        }

        public void Navigate(string url)
        {
            context.Send(a => window.Browser.Address = url, null);
        }

        public void Open()
        {
            window.Show();
        }

        public bool? OpenDialog()
        {
            return window.ShowDialog();
        }

        public void DeleteCookies(string url, string name)
        {
            Cef.GetGlobalCookieManager().DeleteCookies(url, name);
        }

        public void SetCookies(string url, string domain, string name, string value, string path, DateTime expires)
        {
            Cef.GetGlobalCookieManager().SetCookie(url, new Cookie()
            {
                Domain = domain,
                Name = name,
                Value = value,
                Expires = expires,
                Creation = DateTime.Now,
                HttpOnly = false,
                LastAccess = DateTime.Now,
                Secure = false,
                Path = path
            });
        }
    }
}
