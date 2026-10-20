import SwiftUI
import WidgetKit

struct BananaEntry: TimelineEntry {
    let date: Date
    let stats: BananaStats
}

struct BananaProvider: TimelineProvider {
    func placeholder(in context: Context) -> BananaEntry { BananaEntry(date: Date(), stats: .preview) }
    func getSnapshot(in context: Context, completion: @escaping (BananaEntry) -> Void) {
        if context.isPreview { completion(BananaEntry(date: Date(), stats: .preview)); return }
        Task { completion(BananaEntry(date: Date(), stats: await BananaStats.fetch())) }
    }
    func getTimeline(in context: Context, completion: @escaping (Timeline<BananaEntry>) -> Void) {
        Task {
            let stats = await BananaStats.fetch()
            let now = Date()
            // WidgetKit decides the real cadence; ~15 min is the fastest it honors in practice.
            let next = Calendar.current.date(byAdding: .minute, value: 15, to: now)!
            completion(Timeline(entries: [BananaEntry(date: now, stats: stats)], policy: .after(next)))
        }
    }
}

struct BananaWidgetView: View {
    @Environment(\.widgetFamily) private var family
    let entry: BananaEntry

    var body: some View {
        Group {
            switch family {
            case .systemMedium: medium
            case .accessoryRectangular: accessoryRectangular
            case .accessoryCircular: accessoryCircular
            case .accessoryInline: accessoryInline
            default: small
            }
        }
        .widgetURL(BananaStats.statsPage)
        .containerBackground(for: .widget) {
            // Lock Screen families are monochrome and draw their own vibrant
            // material; the banana gradient is for the Home Screen sizes only.
            if isAccessory { Color.clear } else {
                LinearGradient(colors: [Color(red: 0.98, green: 0.84, blue: 0.25), Color(red: 0.96, green: 0.66, blue: 0.12)],
                               startPoint: .topLeading, endPoint: .bottomTrailing)
            }
        }
    }

    private var isAccessory: Bool {
        switch family {
        case .accessoryRectangular, .accessoryCircular, .accessoryInline: return true
        default: return false
        }
    }

    // MARK: Lock Screen (accessory) families

    private var accessoryRectangular: some View {
        VStack(alignment: .leading, spacing: 1) {
            Text("🍌 PLAYING NOW").font(.caption2.weight(.bold)).widgetAccentable()
            Text(Fmt.num(entry.stats.players))
                .font(.system(size: 26, weight: .heavy, design: .rounded))
                .minimumScaleFactor(0.6).lineLimit(1)
            Text("\(Fmt.num(entry.stats.wishlists)) wishlists · \(Fmt.signed(entry.stats.wishlistsToday)) today")
                .font(.caption2).lineLimit(1).minimumScaleFactor(0.7)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var accessoryCircular: some View {
        ZStack {
            AccessoryWidgetBackground()
            VStack(spacing: 0) {
                Text("🍌").font(.caption)
                Text(Fmt.num(entry.stats.players))
                    .font(.system(size: 20, weight: .heavy, design: .rounded))
                    .minimumScaleFactor(0.5).lineLimit(1)
            }
        }
    }

    private var accessoryInline: some View {
        Text("🍌 \(Fmt.num(entry.stats.players)) playing · \(Fmt.num(entry.stats.wishlists)) wishlists")
    }

    private var small: some View {
        VStack(alignment: .leading, spacing: 2) {
            HStack(spacing: 4) {
                Text("🍌").font(.title3)
                Text("PLAYING NOW").font(.caption2.weight(.bold)).foregroundStyle(.black.opacity(0.6))
            }
            Text(Fmt.num(entry.stats.players))
                .font(.system(size: 44, weight: .heavy, design: .rounded))
                .minimumScaleFactor(0.5).lineLimit(1)
                .foregroundStyle(.black)
            Spacer(minLength: 0)
            Text("\(Fmt.num(entry.stats.wishlists)) wishlists")
                .font(.footnote.weight(.semibold))
                .foregroundStyle(.black.opacity(0.75))
                .lineLimit(1).minimumScaleFactor(0.7)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
    }

    private var medium: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(alignment: .top, spacing: 12) {
                stat(title: "🍌 PLAYING NOW", value: Fmt.num(entry.stats.players), sub: "in the demo")
                Divider().overlay(.black.opacity(0.2))
                stat(title: "WISHLISTS", value: Fmt.num(entry.stats.wishlists), sub: "\(Fmt.signed(entry.stats.wishlistsToday)) today")
            }
            Spacer(minLength: 0)
            Text("Updated \(Fmt.time(entry.stats.updatedAt))")
                .font(.caption2).foregroundStyle(.black.opacity(0.55))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
    }

    private func stat(title: String, value: String, sub: String) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(title).font(.caption2.weight(.bold)).foregroundStyle(.black.opacity(0.6))
            Text(value)
                .font(.system(size: 36, weight: .heavy, design: .rounded))
                .minimumScaleFactor(0.5).lineLimit(1)
                .foregroundStyle(.black)
            Text(sub).font(.footnote.weight(.semibold)).foregroundStyle(.black.opacity(0.75))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct BananaWidget: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: "BananaStatsWidget", provider: BananaProvider()) { entry in
            BananaWidgetView(entry: entry)
        }
        .configurationDisplayName("Banana Stats")
        .description("Players in the Banana Airways demo and wishlists, live from Steam.")
        .supportedFamilies([.systemSmall, .systemMedium, .accessoryRectangular, .accessoryCircular, .accessoryInline])
    }
}

#Preview("Small", as: .systemSmall) { BananaWidget() } timeline: { BananaEntry(date: .now, stats: .preview); BananaEntry(date: .now, stats: .empty) }
#Preview("Medium", as: .systemMedium) { BananaWidget() } timeline: { BananaEntry(date: .now, stats: .preview) }
#Preview("Lock rect", as: .accessoryRectangular) { BananaWidget() } timeline: { BananaEntry(date: .now, stats: .preview) }
