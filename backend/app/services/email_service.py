import smtplib
from email.mime.text import MIMEText
from email.mime.multipart import MIMEMultipart
from email.mime.base import MIMEBase
from email import encoders
import os
from datetime import datetime

class EmailService:
    # Email configuration - update these with your email settings
    SMTP_SERVER = os.getenv('SMTP_SERVER', 'smtp.gmail.com')
    SMTP_PORT = int(os.getenv('SMTP_PORT', '587'))
    EMAIL_USER = os.getenv('EMAIL_USER', 'support@ustamapp.com')
    EMAIL_PASSWORD = os.getenv('EMAIL_PASSWORD', 'your-app-password')
    SUPPORT_EMAIL = os.getenv('SUPPORT_EMAIL', 'support@ustamapp.com')
    
    @classmethod
    def _send_email(cls, to_email, subject, html_content, reply_to=None):
        """Send email using SMTP"""
        try:
            msg = MIMEMultipart('alternative')
            msg['From'] = cls.EMAIL_USER
            msg['To'] = to_email
            msg['Subject'] = subject
            
            if reply_to:
                msg['Reply-To'] = reply_to
            
            # Add HTML content
            html_part = MIMEText(html_content, 'html', 'utf-8')
            msg.attach(html_part)
            
            # Send email
            server = smtplib.SMTP(cls.SMTP_SERVER, cls.SMTP_PORT)
            server.starttls()
            server.login(cls.EMAIL_USER, cls.EMAIL_PASSWORD)
            server.send_message(msg)
            server.quit()
            
            print(f"Email sent successfully to {to_email}")
            return True
            
        except Exception as e:
            print(f"Failed to send email to {to_email}: {e}")
            return False
    
    @classmethod
    def send_support_ticket_created(cls, ticket):
        """Send email when new support ticket is created"""
        subject = f"[UstamApp] Yeni Destek Talebi #{ticket.ticket_number}"
        
        html_content = f"""
        <!DOCTYPE html>
        <html>
        <head>
            <meta charset="UTF-8">
            <style>
                body {{ font-family: Arial, sans-serif; line-height: 1.6; color: #333; }}
                .container {{ max-width: 600px; margin: 0 auto; padding: 20px; }}
                .header {{ background: linear-gradient(135deg, #1D3354, #2E5984); color: white; padding: 20px; border-radius: 8px 8px 0 0; }}
                .content {{ background: #f9f9f9; padding: 20px; border-radius: 0 0 8px 8px; }}
                .ticket-info {{ background: white; padding: 15px; border-radius: 8px; margin: 15px 0; }}
                .priority-high {{ border-left: 4px solid #ef4444; }}
                .priority-medium {{ border-left: 4px solid #f59e0b; }}
                .priority-low {{ border-left: 4px solid #10b981; }}
                .footer {{ text-align: center; margin-top: 20px; color: #666; font-size: 12px; }}
            </style>
        </head>
        <body>
            <div class="container">
                <div class="header">
                    <h2>🎯 Yeni Destek Talebi</h2>
                    <p>Ticket #{ticket.ticket_number}</p>
                </div>
                <div class="content">
                    <div class="ticket-info priority-{ticket.priority.value}">
                        <h3>{ticket.subject}</h3>
                        <p><strong>Kategori:</strong> {ticket.category.value}</p>
                        <p><strong>Öncelik:</strong> {ticket.priority.value}</p>
                        <p><strong>Kullanıcı:</strong> {ticket.user.first_name} {ticket.user.last_name}</p>
                        <p><strong>Email:</strong> {ticket.user.email}</p>
                        <p><strong>Kullanıcı Tipi:</strong> {ticket.user.user_type}</p>
                        <p><strong>Oluşturma Tarihi:</strong> {ticket.created_at.strftime('%d.%m.%Y %H:%M')}</p>
                    </div>
                    
                    <div class="ticket-info">
                        <h4>📝 Açıklama:</h4>
                        <p>{ticket.description}</p>
                    </div>
                    
                    <p><strong>Bu talebe yanıt vermek için:</strong> Bu emaile reply atın, yanıtınız otomatik olarak kullanıcıya uygulama içinde iletilecektir.</p>
                </div>
                <div class="footer">
                    <p>UstamApp Destek Sistemi | {datetime.now().strftime('%Y')}</p>
                </div>
            </div>
        </body>
        </html>
        """
        
        return cls._send_email(
            to_email=cls.SUPPORT_EMAIL,
            subject=subject,
            html_content=html_content,
            reply_to=ticket.user.email
        )
    
    @classmethod
    def send_support_message_reply(cls, ticket, message):
        """Send email when user replies to support ticket"""
        subject = f"[UstamApp] Yanıt: #{ticket.ticket_number} - {ticket.subject}"
        
        html_content = f"""
        <!DOCTYPE html>
        <html>
        <head>
            <meta charset="UTF-8">
            <style>
                body {{ font-family: Arial, sans-serif; line-height: 1.6; color: #333; }}
                .container {{ max-width: 600px; margin: 0 auto; padding: 20px; }}
                .header {{ background: linear-gradient(135deg, #1D3354, #2E5984); color: white; padding: 20px; border-radius: 8px 8px 0 0; }}
                .content {{ background: #f9f9f9; padding: 20px; border-radius: 0 0 8px 8px; }}
                .message {{ background: white; padding: 15px; border-radius: 8px; margin: 15px 0; border-left: 4px solid #2E5984; }}
                .footer {{ text-align: center; margin-top: 20px; color: #666; font-size: 12px; }}
            </style>
        </head>
        <body>
            <div class="container">
                <div class="header">
                    <h2>💬 Destek Talebi Yanıtı</h2>
                    <p>Ticket #{ticket.ticket_number}</p>
                </div>
                <div class="content">
                    <p><strong>Kullanıcı:</strong> {ticket.user.first_name} {ticket.user.last_name} ({ticket.user.email})</p>
                    <p><strong>Konu:</strong> {ticket.subject}</p>
                    
                    <div class="message">
                        <h4>📩 Yeni Mesaj:</h4>
                        <p>{message.message}</p>
                        <small>Gönderilme: {message.created_at.strftime('%d.%m.%Y %H:%M')}</small>
                    </div>
                    
                    <p><strong>Bu talebe yanıt vermek için:</strong> Bu emaile reply atın, yanıtınız otomatik olarak kullanıcıya uygulama içinde iletilecektir.</p>
                </div>
                <div class="footer">
                    <p>UstamApp Destek Sistemi | {datetime.now().strftime('%Y')}</p>
                </div>
            </div>
        </body>
        </html>
        """
        
        return cls._send_email(
            to_email=cls.SUPPORT_EMAIL,
            subject=subject,
            html_content=html_content,
            reply_to=ticket.user.email
        )
    
    @classmethod
    def send_support_response_to_user(cls, ticket, response_message, support_agent_email):
        """Send support response back to user (called when support replies via email)"""
        subject = f"[UstamApp] Destek Yanıtı #{ticket.ticket_number}"
        
        html_content = f"""
        <!DOCTYPE html>
        <html>
        <head>
            <meta charset="UTF-8">
            <style>
                body {{ font-family: Arial, sans-serif; line-height: 1.6; color: #333; }}
                .container {{ max-width: 600px; margin: 0 auto; padding: 20px; }}
                .header {{ background: linear-gradient(135deg, #1D3354, #2E5984); color: white; padding: 20px; border-radius: 8px 8px 0 0; }}
                .content {{ background: #f9f9f9; padding: 20px; border-radius: 0 0 8px 8px; }}
                .response {{ background: white; padding: 15px; border-radius: 8px; margin: 15px 0; border-left: 4px solid #10b981; }}
                .footer {{ text-align: center; margin-top: 20px; color: #666; font-size: 12px; }}
            </style>
        </head>
        <body>
            <div class="container">
                <div class="header">
                    <h2>✅ Destek Ekibinden Yanıt</h2>
                    <p>Ticket #{ticket.ticket_number}</p>
                </div>
                <div class="content">
                    <p>Merhaba {ticket.user.first_name},</p>
                    <p>Destek talebinize yanıt aldınız:</p>
                    
                    <div class="response">
                        <h4>📩 Destek Ekibi Yanıtı:</h4>
                        <p>{response_message}</p>
                        <small>Yanıtlayan: {support_agent_email}</small>
                    </div>
                    
                    <p><strong>Yanıt vermek için:</strong> UstamApp uygulamasını açın ve Destek bölümünden ticket'ınızı görüntüleyin.</p>
                    
                    <p>Teşekkürler,<br>UstamApp Destek Ekibi</p>
                </div>
                <div class="footer">
                    <p>UstamApp | {datetime.now().strftime('%Y')}</p>
                </div>
            </div>
        </body>
        </html>
        """
        
        return cls._send_email(
            to_email=ticket.user.email,
            subject=subject,
            html_content=html_content
        )