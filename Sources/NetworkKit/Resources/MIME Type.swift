////
////  MIME Type.swift
////  NetworkKit
////
////  Created by Raghav Ahuja on 28/10/20.
////
//
//import Foundation
//
//public enum MIMEType: String {
//    
//    case html
//    case htm
//    case shtml
//    case css
//    case xml
//    case gif
//    case jpeg
//    case jpg
//    case javascript
//    case atom
//    case rss
//    case mml              = "text/mathml"
//    case txt              = "text/plain"
//    case jad              = "text/vnd.sun.j2me.app-descriptor"
//    case wml              = "text/vnd.wap.wml"
//    case htc              = "text/x-component"
//    case png              = "image/png"
//    case tif
//    case tiff
//    case wbmp             = "image/vnd.wap.wbmp"
//    case ico              = "image/x-icon"
//    case jng              = "image/x-jng"
//    case bmp              = "image/x-ms-bmp"
//    case svg
//    case svgz
//    case webp             = "image/webp"
//    case woff             = "application/font-woff"
//    case jar              = "application/java-archive"
//    case war              = "application/java-archive"
//    case ear              = "application/java-archive"
//    case json             = "application/json"
//    case hqx              = "application/mac-binhex40"
//    case doc              = "application/msword"
//    case pdf              = "application/pdf"
//    case ps               = "application/postscript"
//    case eps              = "application/postscript"
//    case ai               = "application/postscript"
//    case rtf              = "application/rtf"
//    case m3u8             = "application/vnd.apple.mpegurl"
//    case xls              = "application/vnd.ms-excel"
//    case eot              = "application/vnd.ms-fontobject"
//    case ppt              = "application/vnd.ms-powerpoint"
//    case wmlc             = "application/vnd.wap.wmlc"
//    case kml              = "application/vnd.google-earth.kml+xml"
//    case kmz              = "application/vnd.google-earth.kmz"
//    case seven7z               = "application/x-7z-compressed"
//    case cco              = "application/x-cocoa"
//    case jardiff          = "application/x-java-archive-diff"
//    case jnlp             = "application/x-java-jnlp-file"
//    case run              = "application/x-makeself"
//    case pl               = "application/x-perl"
//    case pm               = "application/x-perl"
//    case prc              = "application/x-pilot"
//    case pdb              = "application/x-pilot"
//    case rar              = "application/x-rar-compressed"
//    case rpm              = "application/x-redhat-package-manager"
//    case sea              = "application/x-sea"
//    case swf              = "application/x-shockwave-flash"
//    case sit              = "application/x-stuffit"
//    case tcl              = "application/x-tcl"
//    case tk               = "application/x-tcl"
//    case der              = "application/x-x509-ca-cert"
//    case pem              = "application/x-x509-ca-cert"
//    case crt              = "application/x-x509-ca-cert"
//    case xpi              = "application/x-xpinstall"
//    case xhtml            = "application/xhtml+xml"
//    case xspf             = "application/xspf+xml"
//    case zip              = "application/zip"
//    case bin              = "application/octet-stream"
//    case exe              = "application/octet-stream"
//    case dll              = "application/octet-stream"
//    case deb              = "application/octet-stream"
//    case dmg              = "application/octet-stream"
//    case iso              = "application/octet-stream"
//    case img              = "application/octet-stream"
//    case msi              = "application/octet-stream"
//    case msp              = "application/octet-stream"
//    case msm              = "application/octet-stream"
//    case docx             = "application/vnd.openxmlformats-officedocument.wordprocessingml.document"
//    case xlsx             = "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"
//    case pptx             = "application/vnd.openxmlformats-officedocument.presentationml.presentation"
//    case mid              = "audio/midi"
//    case midi             = "audio/midi"
//    case kar              = "audio/midi"
//    case mp3              = "audio/mpeg"
//    case ogg              = "audio/ogg"
//    case m4a              = "audio/x-m4a"
//    case ra               = "audio/x-realaudio"
//    case three3gpp        = "video/3gpp"
//    case three3gp         = "video/3gpp"
//    case ts               = "video/mp2t"
//    case mp4              = "video/mp4"
//    case mpeg             = "video/mpeg"
//    case mpg              = "video/mpeg"
//    case mov              = "video/quicktime"
//    case webm             = "video/webm"
//    case flv              = "video/x-flv"
//    case m4v              = "video/x-m4v"
//    case mng              = "video/x-mng"
//    case asx
//    case asf
//    case wmv
//    case avi
//    
//    public static func match(for mimeTypeString: String) -> [MIMEType] {
//        switch mimeTypeString {
//        
//        case "text/html":
//            return [.htm, .html, .shtml]
//            
//        case "text/css":
//            return [.css]
//            
//        case "text/xml", "application/xml":
//            return [.xml]
//            
//        case "image/gif":
//            return [.gif]
//            
//        case "image/jpeg":
//            return [.jpeg, .jpg]
//            
//        case "application/javascript":
//            return [.javascript]
//            
//        case "application/atom+xml":
//            return [.atom]
//            
//        case "application/rss+xml":
//            return [.rss]
//            
//        case "image/tiff":
//            return [.tif, .tiff]
//            
//        case "image/svg+xml":
//            return [.svg, .svgz]
//        
//        case "video/x-ms-asf":
//            return [.asx, .asf]
//            
//        case "video/x-ms-wmv":
//            return [.wmv]
//            
//        case "video/x-msvideo":
//            return [.avi]
//            
//        default:
//            return [.txt]
//        }
//    }
//}
