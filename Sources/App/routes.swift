import Fluent
import Vapor
import TelegramBot
import TelegramBotVapor

func routes(_ app: Application) throws {
    // Telegram webhooks
    let telegramBot = TelegramReceiveApi()
    let controller = BotController(
        app: app
    )

    telegramBot.messageUpdate = controller.getMessage
    telegramBot.callbackQueryUpdate = controller.getCallback

    telegramBot.setupWebhook(path: app.customConfigService.telegramToken, routerFunction: app.telegramRegister)
}
