import SwiftUI
import SwiftData

struct CalendarHeatmapView: View {
    @Query(sort: \Session.timestamp, order: .reverse) private var sessions: [Session]

    private let calendar = Calendar.current
    private let columns = Array(repeating: GridItem(.flexible(), spacing: 4), count: 7)
    private let weekdays = ["S", "M", "T", "W", "T", "F", "S"]

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header
            HStack {
                Text("Training Calendar")
                    .font(.headline)
                Spacer()
                Text("\(sessionsThisMonth) sessions this month")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            // Weekday headers
            HStack(spacing: 4) {
                ForEach(weekdays, id: \.self) { day in
                    Text(day)
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity)
                }
            }

            // Calendar grid
            LazyVGrid(columns: columns, spacing: 4) {
                ForEach(daysInMonth, id: \.self) { date in
                    if let date = date {
                        CalendarDayCell(date: date, sessionCount: sessionCount(for: date))
                    } else {
                        Color.clear
                            .aspectRatio(1, contentMode: .fit)
                    }
                }
            }

            // Legend
            HStack(spacing: 16) {
                Spacer()
                LegendItem(color: Color(.systemGray5), label: "None")
                LegendItem(color: .orange.opacity(0.3), label: "1")
                LegendItem(color: .orange.opacity(0.6), label: "2")
                LegendItem(color: .orange, label: "3+")
            }
            .font(.caption2)
        }
        .padding()
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private var sessionsThisMonth: Int {
        let startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: Date()))!
        return sessions.filter { $0.timestamp >= startOfMonth }.count
    }

    private var daysInMonth: [Date?] {
        let now = Date()
        let startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: now))!

        let range = calendar.range(of: .day, in: .month, for: now)!
        let firstWeekday = calendar.component(.weekday, from: startOfMonth) - 1

        var days: [Date?] = Array(repeating: nil, count: firstWeekday)

        for day in range {
            if let date = calendar.date(byAdding: .day, value: day - 1, to: startOfMonth) {
                days.append(date)
            }
        }

        // Fill remaining cells
        while days.count % 7 != 0 {
            days.append(nil)
        }

        return days
    }

    private func sessionCount(for date: Date) -> Int {
        sessions.filter { calendar.isDate($0.timestamp, inSameDayAs: date) }.count
    }
}

struct CalendarDayCell: View {
    let date: Date
    let sessionCount: Int

    private var isToday: Bool {
        Calendar.current.isDateInToday(date)
    }

    private var isFuture: Bool {
        date > Date()
    }

    private var cellColor: Color {
        if isFuture { return Color(.systemGray6) }
        switch sessionCount {
        case 0: return Color(.systemGray5)
        case 1: return .orange.opacity(0.3)
        case 2: return .orange.opacity(0.6)
        default: return .orange
        }
    }

    var body: some View {
        Text("\(Calendar.current.component(.day, from: date))")
            .font(.caption2)
            .frame(maxWidth: .infinity)
            .aspectRatio(1, contentMode: .fit)
            .background(cellColor)
            .clipShape(RoundedRectangle(cornerRadius: 4))
            .overlay {
                if isToday {
                    RoundedRectangle(cornerRadius: 4)
                        .stroke(Color.orange, lineWidth: 2)
                }
            }
            .foregroundStyle(isFuture ? Color.gray.opacity(0.3) : (sessionCount > 0 ? Color.white : Color.primary))
    }
}

struct LegendItem: View {
    let color: Color
    let label: String

    var body: some View {
        HStack(spacing: 4) {
            RoundedRectangle(cornerRadius: 2)
                .fill(color)
                .frame(width: 12, height: 12)
            Text(label)
                .foregroundStyle(.secondary)
        }
    }
}
