import Foundation
import PDFKit
#if canImport(UIKit)
import UIKit
#endif

class PDFExportService {
    static let shared = PDFExportService()

    private init() {}

    func generateStudentReport(student: Student) -> Data? {
        let pageWidth: CGFloat = 595.2  // A4 width in points
        let pageHeight: CGFloat = 841.8 // A4 height in points
        let margin: CGFloat = 40

        let pdfMetaData = [
            kCGPDFContextCreator: "Student Course Manager",
            kCGPDFContextAuthor: "Teacher",
            kCGPDFContextTitle: "\(student.name) - 学习报告"
        ]

        let format = UIGraphicsPDFRendererFormat()
        format.documentInfo = pdfMetaData as [String: Any]

        let renderer = UIGraphicsPDFRenderer(bounds: CGRect(x: 0, y: 0, width: pageWidth, height: pageHeight), format: format)

        let data = renderer.pdfData { context in
            context.beginPage()

            var yPosition: CGFloat = margin

            // Title
            let titleFont = UIFont.boldSystemFont(ofSize: 24)
            let title = "\(student.name) - 阶段学习报告"
            let titleAttributes: [NSAttributedString.Key: Any] = [
                .font: titleFont,
                .foregroundColor: UIColor.black
            ]
            title.draw(at: CGPoint(x: margin, y: yPosition), withAttributes: titleAttributes)
            yPosition += 40

            // Student Info Section
            let headerFont = UIFont.boldSystemFont(ofSize: 16)
            let bodyFont = UIFont.systemFont(ofSize: 12)

            "基本信息".draw(at: CGPoint(x: margin, y: yPosition), withAttributes: [
                .font: headerFont,
                .foregroundColor: UIColor.black
            ])
            yPosition += 25

            let infoLines = [
                "姓名: \(student.name)",
                "性别: \(student.gender.isEmpty ? "未设置" : student.gender)",
                "年级: \(student.grade)",
                "学校: \(student.school.isEmpty ? "未设置" : student.school)",
                "班级: \(student.className ?? "未设置")",
                "电话: \(student.phone)",
                "家长电话: \(student.parentPhone)"
            ]

            for line in infoLines {
                line.draw(at: CGPoint(x: margin + 10, y: yPosition), withAttributes: [
                    .font: bodyFont,
                    .foregroundColor: UIColor.darkGray
                ])
                yPosition += 18
            }

            yPosition += 20

            // Recent Lessons
            "近期课程记录".draw(at: CGPoint(x: margin, y: yPosition), withAttributes: [
                .font: headerFont,
                .foregroundColor: UIColor.black
            ])
            yPosition += 25

            let lessons = DatabaseService.shared.getLessons(forStudentId: student.id ?? 0)
            let recentLessons = Array(lessons.prefix(5))

            if recentLessons.isEmpty {
                "暂无课程记录".draw(at: CGPoint(x: margin + 10, y: yPosition), withAttributes: [
                    .font: bodyFont,
                    .foregroundColor: UIColor.gray
                ])
                yPosition += 18
            } else {
                for lesson in recentLessons {
                    let lessonLine = "\(formatDate(lesson.lessonDate)) - \(lesson.subject): \(lesson.content)"
                    lessonLine.draw(at: CGPoint(x: margin + 10, y: yPosition), withAttributes: [
                        .font: bodyFont,
                        .foregroundColor: UIColor.darkGray
                    ])
                    yPosition += 18
                }
            }

            yPosition += 20

            // Exam Scores
            "考试成绩记录".draw(at: CGPoint(x: margin, y: yPosition), withAttributes: [
                .font: headerFont,
                .foregroundColor: UIColor.black
            ])
            yPosition += 25

            let examScores = DatabaseService.shared.getExamScores(forStudentId: student.id ?? 0)
            let recentScores = Array(examScores.prefix(5))

            if recentScores.isEmpty {
                "暂无考试记录".draw(at: CGPoint(x: margin + 10, y: yPosition), withAttributes: [
                    .font: bodyFont,
                    .foregroundColor: UIColor.gray
                ])
                yPosition += 18
            } else {
                for score in recentScores {
                    if let exam = DatabaseService.shared.getAllExams().first(where: { $0.id == score.examId }) {
                        let scoreLine = "\(formatDate(exam.date)) - \(exam.name): 总分 \(String(format: "%.1f", score.totalScore))"
                        scoreLine.draw(at: CGPoint(x: margin + 10, y: yPosition), withAttributes: [
                            .font: bodyFont,
                            .foregroundColor: UIColor.darkGray
                        ])
                        yPosition += 18
                    }
                }
            }

            yPosition += 20

            // Weak Points
            "薄弱点汇总".draw(at: CGPoint(x: margin, y: yPosition), withAttributes: [
                .font: headerFont,
                .foregroundColor: UIColor.black
            ])
            yPosition += 25

            let weakPoints = DatabaseService.shared.getWeakPoints(forStudentId: student.id ?? 0)
            let uniqueTopics = Array(Set(weakPoints.map { $0.topic }))

            if uniqueTopics.isEmpty {
                "暂无薄弱点记录".draw(at: CGPoint(x: margin + 10, y: yPosition), withAttributes: [
                    .font: bodyFont,
                    .foregroundColor: UIColor.gray
                ])
                yPosition += 18
            } else {
                for topic in uniqueTopics.prefix(10) {
                    let topicLine = "• \(topic)"
                    topicLine.draw(at: CGPoint(x: margin + 10, y: yPosition), withAttributes: [
                        .font: bodyFont,
                        .foregroundColor: UIColor.darkGray
                    ])
                    yPosition += 18
                }
            }

            // Footer
            let footerFont = UIFont.systemFont(ofSize: 10)
            let footer = "生成时间: \(formatDate(Date()))"
            footer.draw(at: CGPoint(x: margin, y: pageHeight - margin), withAttributes: [
                .font: footerFont,
                .foregroundColor: UIColor.lightGray
            ])
        }

        return data
    }

    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
}
