//
//  AttachmentPicker.swift
//  MediationAI
//
//  Created by Linda Alster on 7/14/25.
//


import SwiftUI
import PhotosUI

struct AttachmentPicker: UIViewControllerRepresentable {
    @Binding var attachments: [Attachment]
    
    func makeUIViewController(context: Context) -> PHPickerViewController {
        var config = PHPickerConfiguration()
        config.selectionLimit = 3
        config.filter = .any(of: [.images, .livePhotos])
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, PHPickerViewControllerDelegate {
        let parent: AttachmentPicker
        init(_ parent: AttachmentPicker) { self.parent = parent }
        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            picker.dismiss(animated: true)
            for result in results {
                result.itemProvider.loadObject(ofClass: UIImage.self) { object, error in
                    if let image = object as? UIImage, let data = image.jpegData(compressionQuality: 0.8) {
                        let att = Attachment(
                            id: UUID(),
                            fileName: "image.jpg",
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
}

struct AttachmentPreview: View {
    let attachment: Attachment
    var body: some View {
        if attachment.fileType == .image, let uiImage = UIImage(data: attachment.fileData) {
            Image(uiImage: uiImage)
                .resizable()
                .scaledToFill()
                .frame(width: 60, height: 60)
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .shadow(radius: 2)
        } else {
            Image(systemName: "doc")
                .resizable()
                .frame(width: 40, height: 50)
                .foregroundColor(.gray)
        }
    }
}
