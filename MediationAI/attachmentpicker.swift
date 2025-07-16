//
//  AttachmentPicker.swift
//  MediationAI
//
//  Created by Linda Alster on 7/14/25.
//

import SwiftUI
import PhotosUI
import UniformTypeIdentifiers

struct AttachmentPicker: UIViewControllerRepresentable {
    @Binding var attachments: [Attachment]
    @State private var showingDocumentPicker = false
    
    func makeUIViewController(context: Context) -> UIViewController {
        let controller = UIViewController()
        
        DispatchQueue.main.async {
            let alertController = UIAlertController(title: "Add Attachment", message: "Choose attachment type", preferredStyle: .actionSheet)
            
            alertController.addAction(UIAlertAction(title: "Photo/Video", style: .default) { _ in
                self.presentPhotoPicker(from: controller)
            })
            
            alertController.addAction(UIAlertAction(title: "Document", style: .default) { _ in
                self.presentDocumentPicker(from: controller)
            })
            
            alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel))
            
            controller.present(alertController, animated: true)
        }
        
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}
    
    private func presentPhotoPicker(from viewController: UIViewController) {
        var config = PHPickerConfiguration()
        config.selectionLimit = 3
        config.filter = .any(of: [.images, .videos])
        
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = PhotoPickerCoordinator(parent: self)
        viewController.present(picker, animated: true)
    }
    
    private func presentDocumentPicker(from viewController: UIViewController) {
        let picker = UIDocumentPickerViewController(forOpeningContentTypes: [
            .pdf,
            .plainText,
            .rtf,
            .data,
            UTType(mimeType: "application/msword") ?? .data,
            UTType(mimeType: "application/vnd.openxmlformats-officedocument.wordprocessingml.document") ?? .data
        ])
        picker.allowsMultipleSelection = true
        picker.delegate = DocumentPickerCoordinator(parent: self)
        viewController.present(picker, animated: true)
    }
    
    class PhotoPickerCoordinator: NSObject, PHPickerViewControllerDelegate {
        let parent: AttachmentPicker
        
        init(parent: AttachmentPicker) {
            self.parent = parent
        }
        
        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            picker.dismiss(animated: true)
            
            for result in results {
                result.itemProvider.loadObject(ofClass: UIImage.self) { object, error in
                    if let image = object as? UIImage, let data = image.jpegData(compressionQuality: 0.8) {
                        let fileName = "image_\(UUID().uuidString.prefix(8)).jpg"
                        let att = Attachment(
                            fileName: fileName,
                            fileData: data,
                            fileType: .image
                        )
                        DispatchQueue.main.async {
                            self.parent.attachments.append(att)
                        }
                    }
                }
            }
        }
    }
    
    class DocumentPickerCoordinator: NSObject, UIDocumentPickerDelegate {
        let parent: AttachmentPicker
        
        init(parent: AttachmentPicker) {
            self.parent = parent
        }
        
        func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
            for url in urls {
                guard url.startAccessingSecurityScopedResource() else { continue }
                defer { url.stopAccessingSecurityScopedResource() }
                
                do {
                    let data = try Data(contentsOf: url)
                    let fileName = url.lastPathComponent
                    let fileType: FileType = {
                        switch url.pathExtension.lowercased() {
                        case "pdf": return .document
                        case "doc", "docx": return .document
                        case "txt", "rtf": return .document
                        case "jpg", "jpeg", "png", "gif": return .image
                        default: return .document
                        }
                    }()
                    
                    let attachment = Attachment(
                        fileName: fileName,
                        fileData: data,
                        fileType: fileType
                    )
                    
                    DispatchQueue.main.async {
                        self.parent.attachments.append(attachment)
                    }
                } catch {
                    print("Error loading document: \(error)")
                }
            }
        }
    }
}

struct AttachmentPreview: View {
    let attachment: Attachment
    
    var body: some View {
        VStack(spacing: 4) {
            if attachment.fileType == .image, let uiImage = UIImage(data: attachment.fileData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 60, height: 60)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .shadow(radius: 2)
            } else {
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(AppTheme.cardGradient)
                        .frame(width: 60, height: 60)
                        .shadow(radius: 2)
                    
                    VStack(spacing: 2) {
                        Image(systemName: documentIcon)
                            .font(.title2)
                            .foregroundColor(AppTheme.primary)
                        
                        Text(fileExtension)
                            .font(.caption2)
                            .foregroundColor(AppTheme.textSecondary)
                            .fontWeight(.medium)
                    }
                }
            }
            
            Text(truncatedFileName)
                .font(.caption2)
                .foregroundColor(AppTheme.textSecondary)
                .lineLimit(2)
                .multilineTextAlignment(.center)
                .frame(width: 60)
        }
    }
    
    private var documentIcon: String {
        switch attachment.fileName.split(separator: ".").last?.lowercased() {
        case "pdf": return "doc.fill"
        case "doc", "docx": return "doc.text.fill"
        case "txt": return "doc.plaintext.fill"
        default: return "doc.fill"
        }
    }
    
    private var fileExtension: String {
        String(attachment.fileName.split(separator: ".").last?.uppercased() ?? "DOC")
    }
    
    private var truncatedFileName: String {
        let name = attachment.fileName
        if name.count > 12 {
            let startIndex = name.startIndex
            let endIndex = name.index(startIndex, offsetBy: 8)
            return String(name[startIndex...endIndex]) + "..."
        }
        return name
    }
}
