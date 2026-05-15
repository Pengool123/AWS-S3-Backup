const { SNSClient, PublishCommand } = require("@aws-sdk/client-sns");
const client = new SNSClient({});

exports.handler = async (event) => {
    const message = JSON.parse(event.Records[0].Sns.Message);
    const status = message.State;

    const customMsg = status == "COMPLETED" ?
    `Backup succeeded for ${message.resourceArn} at ${message.completionDate}`
    : `Backup failed for ${message.resourceArn}. Reason: ${message.statusMessage}`;

    console.log(customMsg)

    await client.send(new PublishCommand({
        TopicArn: process.env.SNS_TOPIC_ARN,
        Message: customMsg,
        Subject: status == "COMPLETED" ? "Backup Succeeded" : "Backup Failed"
    }));
};